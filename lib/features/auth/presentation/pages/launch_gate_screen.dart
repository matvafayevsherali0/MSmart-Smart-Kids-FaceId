import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/router.dart';
import '../../../../assets/colors/colors.dart';
import '../../../../core/storage/storage.dart';
import '../../../../core/storage/store_keys.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/vault/vault_update_service.dart';
import '../dialog/auth_dialogs.dart';

class LaunchGateScreen extends StatefulWidget {
  const LaunchGateScreen({super.key});

  @override
  State<LaunchGateScreen> createState() => _LaunchGateScreenState();
}

class _LaunchGateScreenState extends State<LaunchGateScreen> {
  final _storage = serviceLocator<StorageRepository>();
  final _vaultUpdateService = serviceLocator<VaultUpdateService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveRoute());
  }

  Future<void> _resolveRoute() async {
    debugPrint("[LaunchGateScreen] start resolve route");
    final updateResult = await _vaultUpdateService.checkForForceUpdate();
    if (!mounted) return;
    if (updateResult.required) {
      debugPrint("[LaunchGateScreen] show force update dialog");
      await showForceUpdateDialog(
        context,
        onUpdate: () => _vaultUpdateService.openStore(updateResult.storeUrl),
      );
      return;
    }

    final token = _storage.getString(StoreKeys.accessToken);
    final pin = _storage.getString(StoreKeys.pinCode);
    if (!mounted) return;

    if (token.isEmpty) {
      context.go(AppRoutes.signIn);
      return;
    }

    if (pin.isEmpty) {
      context.go(AppRoutes.pin, extra: {'isSetup': true});
      return;
    }

    context.go(AppRoutes.pin, extra: {'isSetup': false});
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: cBlack)),
    );
  }
}
