import 'dart:convert';

import 'package:get/get.dart';

import '../../features/auth/data/property_partner_repo.dart';
import '../models/partner_models.dart';
import '../network/api_service.dart';
import '../routes/app_routes.dart';
import '../storage/secure_storage_service.dart';

/// Shared GetX controller for Partner/Agent dashboard tabs.
class PartnerHomeController extends GetxController {
  PartnerHomeController({PartnerRepository? repository})
      : _repo = repository ?? PartnerRepository(ApiService.instance);

  final PartnerRepository _repo;

  final RxBool isBootstrapping = true.obs;
  final RxnString error = RxnString();
  final RxBool isBypassSession = false.obs;
  final RxBool usingFallbackPacks = false.obs;

  /// Dashboard listens and switches bottom-nav tab when set.
  final RxnInt requestedTab = RxnInt();

  final RxString partnerId = ''.obs;
  final RxString partnerName = 'Partner'.obs;
  final RxBool isVerifiedPartner = false.obs;
  final RxString accountType = 'single'.obs;
  final RxBool isTeamOwner = false.obs;

  // Credits
  final RxInt creditBalance = 0.obs;
  final RxBool creditsLoading = false.obs;
  final RxList<Map<String, dynamic>> creditHistory =
      <Map<String, dynamic>>[].obs;
  final RxList<CreditPack> creditPacks = <CreditPack>[].obs;
  final RxBool purchaseLoading = false.obs;

  // Leads
  final RxBool leadsLoading = false.obs;
  final Rxn<PartnerLeadsDashboard> leadsDashboard = Rxn<PartnerLeadsDashboard>();
  final RxList<PartnerLead> leads = <PartnerLead>[].obs;
  final RxString leadsTab = 'Available'.obs;
  final RxBool unlockLoading = false.obs;

  // Properties
  final RxBool propertiesLoading = false.obs;
  final RxList<PartnerProperty> properties = <PartnerProperty>[].obs;
  final Rxn<PublishingSummary> publishingSummary = Rxn<PublishingSummary>();
  final RxString propertiesTab = 'All'.obs;
  final RxString propertySearch = ''.obs;

  // Tasks / visits / unassigned
  final RxBool tasksLoading = false.obs;
  final RxList<PartnerVisit> visits = <PartnerVisit>[].obs;
  final RxList<PartnerProperty> unassignedProperties =
      <PartnerProperty>[].obs;
  final Rxn<VisitsSummary> visitsSummary = Rxn<VisitsSummary>();
  final RxString tasksTab = 'In Progress'.obs;

  // Team
  final RxBool teamLoading = false.obs;
  final RxList<Map<String, dynamic>> teamMembers =
      <Map<String, dynamic>>[].obs;
  final RxList<PartnerProperty> teamProperties = <PartnerProperty>[].obs;

  // Promotions
  final RxBool promotionsLoading = false.obs;
  final RxList<Map<String, dynamic>> promotions = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> boostDashboard =
      Rxn<Map<String, dynamic>>();

  static bool _handlingUnauthorized = false;

  @override
  void onInit() {
    super.onInit();
    ApiService.onUnauthorized = _onUnauthorized;
    bootstrap();
  }

  @override
  void onClose() {
    if (ApiService.onUnauthorized == _onUnauthorized) {
      ApiService.onUnauthorized = null;
    }
    super.onClose();
  }

  void goToProfileTab() => requestedTab.value = 4;

  void goToTab(int index) => requestedTab.value = index;

  Future<void> bootstrap() async {
    isBootstrapping.value = true;
    error.value = null;
    try {
      await _resolvePartnerSession();
      if (isBypassSession.value) {
        // Demo session — skip remote loads so UI stays usable without 401 spam.
        await loadCreditPacks();
        return;
      }
      final futures = <Future>[
        loadCredits(),
        loadLeads(),
        loadProperties(),
        loadTasks(),
        loadCreditPacks(),
        loadPromotions(),
      ];
      if (isTeamOwner.value) futures.add(loadTeam());
      await Future.wait(futures);
    } catch (e) {
      error.value = e.toString();
      _handleError(e);
    } finally {
      isBootstrapping.value = false;
    }
  }

  Future<void> refreshAll() => bootstrap();

  Future<void> _resolvePartnerSession() async {
    final raw = await SecureStorageService.instance.getUserData();
    if (raw == null || raw.isEmpty) {
      throw PartnerApiException(
        'No partner session found. Please log in again.',
      );
    }
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    isBypassSession.value = map['isBypass'] == true;

    final id = asString(map['_id']) ??
        asString(map['id']) ??
        asString(map['partnerId']) ??
        '';
    if (id.isEmpty) {
      throw PartnerApiException('Partner id missing from session.');
    }
    partnerId.value = id;
    partnerName.value =
        asString(map['name']) ?? asString(map['fullName']) ?? 'Partner';
    accountType.value = asString(map['accountType']) ?? 'single';
    isTeamOwner.value = accountType.value.toLowerCase().contains('agency') ||
        accountType.value.toLowerCase().contains('team') ||
        asString(map['teamRole'])?.toLowerCase() == 'owner' ||
        map['parentPartnerId'] == null &&
            (accountType.value.toLowerCase() != 'subagent' &&
                accountType.value.toLowerCase() != 'single');
    if (accountType.value.toLowerCase() == 'single' ||
        accountType.value.toLowerCase() == 'subagent') {
      isTeamOwner.value = false;
    }
    if (accountType.value.toLowerCase().contains('agency') ||
        asString(map['teamRole'])?.toLowerCase() == 'owner') {
      isTeamOwner.value = true;
    }
    isVerifiedPartner.value = map['isVerified'] == true ||
        asString(map['status'])?.toLowerCase() == 'verified' ||
        asString(map['role'])?.toLowerCase() == 'partner' ||
        asString(map['role'])?.toLowerCase() == 'agent';

    if (isBypassSession.value) return;

    try {
      final profile = await _repo.getPartnerById(id);
      partnerName.value = profile.name;
      isVerifiedPartner.value = profile.isVerified || isVerifiedPartner.value;
    } catch (e) {
      _handleError(e, silent: true);
    }
  }

  void _onUnauthorized() {
    if (isBypassSession.value) return;
    forceLogout(reason: 'Session expired. Please log in again.');
  }

  Future<void> forceLogout({String? reason}) async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      await _repo.clearPartnerSession();
      if (Get.isRegistered<PartnerHomeController>()) {
        // Defer delete until after navigation frame.
      }
      if (reason != null && reason.isNotEmpty) {
        Get.snackbar('Signed out', reason, snackPosition: SnackPosition.BOTTOM);
      }
      Get.offAllNamed(AppRoutes.partnerLogin);
      if (Get.isRegistered<PartnerHomeController>()) {
        Get.delete<PartnerHomeController>(force: true);
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _handlingUnauthorized = false;
      });
    }
  }

  Future<void> logout() => forceLogout(reason: 'Logged out');

  void _handleError(Object e, {bool silent = false}) {
    if (e is PartnerApiException && e.isUnauthorized) {
      forceLogout(reason: 'Session expired. Please log in again.');
      return;
    }
    if (isBypassSession.value || silent) return;
    _toast(e.toString(), isError: true);
  }

  Future<void> loadCredits() async {
    if (partnerId.value.isEmpty || isBypassSession.value) return;
    creditsLoading.value = true;
    try {
      final snap = await _repo.getPartnerCredits(partnerId.value);
      creditBalance.value = snap.wallet.balance;
      if (snap.partner != null) {
        partnerName.value = snap.partner!.name;
      }
      final history = await _repo.getCreditsHistory(partnerId: partnerId.value);
      creditHistory.assignAll(
        history.isNotEmpty ? history : snap.recentTransactions,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      creditsLoading.value = false;
    }
  }

  void _toast(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> loadCreditPacks() async {
    try {
      final packs = await _repo.getCreditPacks();
      creditPacks.assignAll(packs);
      usingFallbackPacks.value = packs.any((p) => p.isFallback);
    } catch (_) {
      // defaults handled in repository
      usingFallbackPacks.value = true;
    }
  }

  Future<void> purchasePack(CreditPack pack) async {
    if (partnerId.value.isEmpty || isBypassSession.value) {
      _toast('Sign in with a real partner account to purchase', isError: true);
      return;
    }
    purchaseLoading.value = true;
    try {
      final snap = await _repo.completeCreditPurchase(
        partnerId: partnerId.value,
        credits: pack.credits,
        amountInRupees: pack.priceInr,
        productCode: pack.code,
      );
      creditBalance.value = snap.wallet.balance;
      _toast('${pack.credits} credits added');
      await loadCredits();
    } catch (e) {
      _handleError(e);
    } finally {
      purchaseLoading.value = false;
    }
  }

  Future<void> loadLeads() async {
    if (partnerId.value.isEmpty || isBypassSession.value) return;
    leadsLoading.value = true;
    try {
      final list = await _repo.getPartnerLeads(partnerId.value);
      leads.assignAll(list);
      // Prefer partner-scoped counters; global /leads/dashboard is not
      // reliably scoped to the logged-in partner.
      final unlocked = list.where((l) => l.isUnlocked).length;
      final follow = list
          .where((l) => l.status.toLowerCase().contains('follow'))
          .length;
      final visits = list
          .where((l) => l.status.toLowerCase().contains('visit'))
          .length;
      leadsDashboard.value = PartnerLeadsDashboard({
        'totalLeads': list.length,
        'unlocked': unlocked,
        'available': list.length - unlocked,
        'assigned': list.length,
        'followUp': follow,
        'visitPlanned': visits,
        'convertedLeads': list
            .where((l) => l.status.toLowerCase().contains('convert'))
            .length,
      });
      try {
        final dash = await _repo.getLeadsDashboard();
        // Keep global unlocked/assigned only when we have no local leads.
        if (list.isEmpty && dash.totalLeads > 0) {
          // Still show empty partner list; don't overwrite with global pool.
        }
      } catch (_) {}
    } catch (e) {
      _handleError(e);
    } finally {
      leadsLoading.value = false;
    }
  }

  List<PartnerLead> get filteredLeads {
    final tab = leadsTab.value.toLowerCase();
    if (tab == 'available') {
      return leads.where((l) => !l.isUnlocked).toList();
    }
    if (tab == 'unlocked') {
      return leads.where((l) => l.isUnlocked).toList();
    }
    if (tab == 'follow-up' || tab == 'follow up' || tab == 'follow-ups') {
      return leads
          .where(
            (l) => l.status.toLowerCase().contains('follow'),
          )
          .toList();
    }
    if (tab.contains('visit')) {
      return leads
          .where((l) => l.status.toLowerCase().contains('visit'))
          .toList();
    }
    return leads.toList();
  }

  Future<void> unlockLead(PartnerLead lead) async {
    if (lead.id.isEmpty || partnerId.value.isEmpty || isBypassSession.value) {
      return;
    }
    unlockLoading.value = true;
    try {
      final body = await _repo.unlockLead(
        lead.id,
        partnerId: partnerId.value,
        remarks: 'Unlocked by partner app',
      );
      final data = asMap(body['data']);
      final wallet = asMap(data['wallet']);
      final bal = asInt(wallet['balance']) ??
          asInt(wallet['credits']) ??
          asInt(wallet['availableBalance']);
      if (bal != null) creditBalance.value = bal;
      _toast(asString(body['message']) ?? 'Lead unlocked');
      await Future.wait([loadLeads(), loadCredits()]);
    } catch (e) {
      _handleError(e);
    } finally {
      unlockLoading.value = false;
    }
  }

  Future<void> setLeadStatus(PartnerLead lead, String status) async {
    if (isBypassSession.value) return;
    try {
      await _repo.updateLeadStatus(lead.id, status: status);
      _toast('Lead updated');
      await loadLeads();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadProperties() async {
    if (partnerId.value.isEmpty || isBypassSession.value) return;
    propertiesLoading.value = true;
    try {
      var list = await _repo.getNewPropertiesByPartner(partnerId.value);
      if (list.isEmpty) {
        try {
          list = await _repo.getPartnerPropertiesAssigned();
        } catch (_) {
          list = const [];
        }
      }
      properties.assignAll(list);
      try {
        publishingSummary.value = await _repo.getPublishingSummary();
      } catch (_) {
        publishingSummary.value = PublishingSummary({
          'assigned': list.length,
          'live': list.where((p) => p.status.toLowerCase() == 'live').length,
          'readyForFinalReview': list
              .where((p) => p.status.toLowerCase().contains('review'))
              .length,
          'draft': list
              .where((p) => p.status.toLowerCase().contains('draft'))
              .length,
        });
      }
    } catch (e) {
      _handleError(e);
    } finally {
      propertiesLoading.value = false;
    }
  }

  List<PartnerProperty> get filteredProperties {
    Iterable<PartnerProperty> list = properties;
    final q = propertySearch.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.address.toLowerCase().contains(q),
      );
    }
    final tab = propertiesTab.value.toLowerCase();
    if (tab == 'all') return list.toList();
    if (tab == 'live') {
      return list
          .where((p) => p.status.toLowerCase() == 'live')
          .toList();
    }
    if (tab.contains('review')) {
      return list
          .where((p) => p.status.toLowerCase().contains('review'))
          .toList();
    }
    if (tab == 'draft') {
      return list
          .where((p) => p.status.toLowerCase().contains('draft'))
          .toList();
    }
    if (tab == 'assigned') {
      return list
          .where((p) => !p.status.toLowerCase().contains('draft'))
          .toList();
    }
    return list.toList();
  }

  int get propAssignedCount =>
      publishingSummary.value?.assigned ?? properties.length;

  int get propLiveCount =>
      publishingSummary.value?.live ??
      properties.where((p) => p.status.toLowerCase() == 'live').length;

  int get propReviewCount =>
      publishingSummary.value?.readyForFinalReview ??
      properties
          .where((p) => p.status.toLowerCase().contains('review'))
          .length;

  int get propDraftCount =>
      properties.where((p) => p.status.toLowerCase().contains('draft')).length;

  Future<void> boostProperty(PartnerProperty property) async {
    if (isBypassSession.value) return;
    try {
      await _repo.createPromotion(
        partnerId: partnerId.value,
        propertyId: property.id,
        promotionType: 'BOOST',
        remarks: 'Requested from partner app',
      );
      _toast('Promotion submitted (credits reserved)');
      await Future.wait([loadProperties(), loadCredits(), loadPromotions()]);
    } catch (e) {
      try {
        await _repo.boostProperty(property.id, boostType: 'STANDARD', days: 7);
        _toast('Property boosted');
        await loadProperties();
        await loadCredits();
      } catch (e2) {
        _handleError(e2);
      }
    }
  }

  Future<void> unboostProperty(PartnerProperty property) async {
    if (isBypassSession.value) return;
    try {
      await _repo.unboostProperty(property.id);
      _toast('Boost removed');
      await loadProperties();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteProperty(PartnerProperty property) async {
    if (isBypassSession.value) return;
    try {
      await _repo.deleteProperty(property.id);
      _toast('Property deleted');
      await loadProperties();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updatePropertyStatus(
    PartnerProperty property,
    String status,
  ) async {
    if (isBypassSession.value) return;
    try {
      await _repo.updatePropertyStatus(property.id, status: status);
      _toast('Status updated');
      await loadProperties();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadTeam() async {
    if (partnerId.value.isEmpty || !isTeamOwner.value || isBypassSession.value) {
      return;
    }
    teamLoading.value = true;
    try {
      final members = await _repo.getVerifiedTeamMembers(partnerId.value);
      final props = await _repo.getTeamAssignedProperties(partnerId.value);
      teamMembers.assignAll(members);
      teamProperties.assignAll(props);
    } catch (e) {
      _handleError(e);
    } finally {
      teamLoading.value = false;
    }
  }

  Future<void> allocateCreditsToMember({
    required String memberId,
    required int credits,
  }) async {
    if (isBypassSession.value) return;
    try {
      await _repo.allocateTeamCredits(
        ownerId: partnerId.value,
        memberId: memberId,
        credits: credits,
      );
      _toast('Credits allocated');
      await Future.wait([loadTeam(), loadCredits()]);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> addSubAgent(Map<String, dynamic> payload) async {
    if (isBypassSession.value) return;
    try {
      await _repo.addTeamMember(partnerId.value, payload);
      _toast('Sub-agent application created');
      await loadTeam();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> delegateProperty({
    required String propertyId,
    String? memberId,
  }) async {
    if (isBypassSession.value) return;
    try {
      await _repo.delegatePropertyToSubAgent(
        ownerId: partnerId.value,
        propertyId: propertyId,
        memberId: memberId,
      );
      _toast('Property delegated');
      await loadTeam();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadPromotions() async {
    if (partnerId.value.isEmpty || isBypassSession.value) return;
    promotionsLoading.value = true;
    try {
      final list = await _repo.getPromotions(partnerId: partnerId.value);
      promotions.assignAll(list);
      final dash = await _repo.getBoostOperationsDashboard(
        partnerId: partnerId.value,
      );
      boostDashboard.value = dash;
    } catch (_) {
      // Non-fatal for tabs that don't show promotions
    } finally {
      promotionsLoading.value = false;
    }
  }

  Future<void> loadTasks() async {
    if (partnerId.value.isEmpty || isBypassSession.value) return;
    tasksLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getPartnerVisits(partnerId.value),
        _repo.getUnassignedProperties(),
        _repo.getVisitsSummary(),
      ]);
      visits.assignAll(results[0] as List<PartnerVisit>);
      unassignedProperties.assignAll(results[1] as List<PartnerProperty>);
      visitsSummary.value = results[2] as VisitsSummary;
    } catch (e) {
      _handleError(e);
    } finally {
      tasksLoading.value = false;
    }
  }

  List<PartnerProperty> get filteredTaskProperties {
    final tab = tasksTab.value.toLowerCase();
    if (tab == 'new') return unassignedProperties.toList();
    return unassignedProperties.toList();
  }

  List<PartnerVisit> get filteredVisits {
    final tab = tasksTab.value.toLowerCase();
    if (tab == 'new') {
      return visits
          .where((v) => v.status.toLowerCase().contains('request'))
          .toList();
    }
    if (tab.contains('progress')) {
      return visits
          .where(
            (v) =>
                !v.status.toLowerCase().contains('complete') &&
                !v.status.toLowerCase().contains('cancel'),
          )
          .toList();
    }
    if (tab == 'verified') {
      return visits
          .where((v) => v.status.toLowerCase().contains('verif'))
          .toList();
    }
    if (tab == 'completed') {
      return visits
          .where((v) => v.status.toLowerCase().contains('complete'))
          .toList();
    }
    return visits.toList();
  }

  Future<void> updateVisitStatus(PartnerVisit visit, String status) async {
    if (isBypassSession.value) return;
    try {
      await _repo.updateVisitStatus(visit.id, status: status);
      _toast('Visit updated');
      await loadTasks();
    } catch (e) {
      _handleError(e);
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final first = partnerName.value.split(' ').first;
    return '$part, $first';
  }
}

/// Ensures a [PartnerHomeController] exists for partner screens/routes.
PartnerHomeController ensurePartnerHomeController() {
  if (Get.isRegistered<PartnerHomeController>()) {
    return Get.find<PartnerHomeController>();
  }
  return Get.put(PartnerHomeController());
}
