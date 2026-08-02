library yabisso_stock;

// Domaine
export 'src/domain/enums.dart';

// Données
export 'src/data/database/stock_database.dart';
export 'src/data/repositories/stock_item_repository.dart';

// Application
export 'src/application/stock_service.dart';
export 'src/application/sync/stock_sync_registrar.dart';

// Présentation — providers
export 'src/presentation/providers/stock_providers.dart';

// Présentation — écrans
export 'src/presentation/screens/stock_dashboard_screen.dart';
export 'src/presentation/screens/product_list_screen.dart';
export 'src/presentation/screens/product_detail_screen.dart';
export 'src/presentation/screens/stock_movement_form_screen.dart';
export 'src/presentation/screens/transfer_screen.dart';
export 'src/presentation/screens/inventory_scan_screen.dart';
export 'src/presentation/screens/alerts_screen.dart';
export 'src/presentation/screens/recipe_config_screen.dart';

// Présentation — widgets
export 'src/presentation/widgets/stock_badges.dart';
