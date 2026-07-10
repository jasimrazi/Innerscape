import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'journal_provider.dart';

/// Centralized list of providers for Innerscape
List<SingleChildWidget> get appProviders => [
      ChangeNotifierProvider(create: (_) => JournalProvider()),
    ];
