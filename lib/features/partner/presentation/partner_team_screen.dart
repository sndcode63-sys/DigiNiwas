import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/partner/controllers/partner_home_controller.dart';
import '../../../features/partner/models/partner_models.dart';

class PartnerTeamScreen extends StatefulWidget {
  const PartnerTeamScreen({super.key});

  @override
  State<PartnerTeamScreen> createState() => _PartnerTeamScreenState();
}

class _PartnerTeamScreenState extends State<PartnerTeamScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _credits = TextEditingController(text: '250');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensurePartnerHomeController().loadTeam();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _credits.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ensurePartnerHomeController();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Team Members'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Obx(() {
        if (!c.isTeamOwner.value) {
          return const Center(
            child: Text('Team management is available for agency owners.'),
          );
        }
        return RefreshIndicator(
          onRefresh: c.loadTeam,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Text('Verified members',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              if (c.teamLoading.value)
                const Center(child: CircularProgressIndicator())
              else if (c.teamMembers.isEmpty)
                Text('No verified members yet',
                    style: TextStyle(color: Colors.grey.shade600))
              else
                ...c.teamMembers.map((m) {
                  final id = asString(m['_id']) ?? asString(m['id']) ?? '';
                  final name = asString(m['name']) ?? 'Member';
                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text(asString(m['email']) ??
                          asString(m['phone']) ??
                          ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        onPressed: () async {
                          final credits =
                              int.tryParse(_credits.text.trim()) ?? 250;
                          await c.allocateCreditsToMember(
                            memberId: id,
                            credits: credits,
                          );
                        },
                      ),
                    ),
                  );
                }),
              SizedBox(height: 16.h),
              Text('Allocate amount (credits)',
                  style: TextStyle(fontSize: 12.sp)),
              TextField(
                controller: _credits,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '250',
                ),
              ),
              SizedBox(height: 20.h),
              Text('Add Sub-Agent',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () => c.addSubAgent({
                  'name': _name.text.trim(),
                  'email': _email.text.trim(),
                  'phone': _phone.text.trim(),
                  'privacyConsent': true,
                  'teamRole': 'subagent',
                  'business': '',
                  'location': '',
                  'rera': '',
                  'identityDocuments': '',
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005B48),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Invite Sub-Agent'),
              ),
              SizedBox(height: 20.h),
              Text('Team properties',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              if (c.teamProperties.isEmpty)
                Text('No team properties',
                    style: TextStyle(color: Colors.grey.shade600))
              else
                ...c.teamProperties.map((p) => Card(
                      child: ListTile(
                        title: Text(p.title),
                        subtitle: Text(p.status),
                        trailing: TextButton(
                          onPressed: () =>
                              c.delegateProperty(propertyId: p.id),
                          child: const Text('Delegate'),
                        ),
                      ),
                    )),
            ],
          ),
        );
      }),
    );
  }
}
