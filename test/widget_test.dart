import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_vault/core/app_strings.dart';
import 'package:electronic_vault/models/models.dart';

void main() {
  test('project JSON round-trip keeps products', () {
    final Project project = Project(
      id: '1',
      vaultId: 'v',
      name: 'Demo',
      description: 'd',
    );
    project.products['apk'] = ProductInfo(
      type: ProductType.apk,
      downloadUrl: 'https://example.com/a.apk',
      downloadCount: 3,
    );

    final Project restored = Project.fromJson(project.toJson());

    expect(restored.name, 'Demo');
    expect(restored.products['apk']!.downloadCount, 3);
    expect(restored.products['apk']!.type, ProductType.apk);
  });

  test('localized strings resolve and RTL is detected', () {
    expect(const AppStrings('en').t('login'), 'Login');
    expect(const AppStrings('ar').t('login'), 'دخول');
    expect(const AppStrings('ar').isRtl, isTrue);
    expect(const AppStrings('en').isRtl, isFalse);
  });
}
