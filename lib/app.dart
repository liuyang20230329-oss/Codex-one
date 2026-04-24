import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/brand/app_brand.dart';
import 'src/core/bootstrap/app_bootstrap.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
import 'src/features/auth/presentation/auth_gate.dart';
import 'src/features/chat/presentation/bloc/chat_bloc.dart';
import 'src/features/circle/presentation/bloc/circle_bloc.dart';

class CodexOneApp extends StatelessWidget {
  const CodexOneApp({
    super.key,
    required this.bootstrap,
  });

  final AppBootstrapResult bootstrap;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(repository: bootstrap.repository),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(repository: bootstrap.chatRepository),
        ),
        BlocProvider<CircleBloc>(
          create: (_) => CircleBloc(repository: bootstrap.circleRepository),
        ),
      ],
      child: MaterialApp(
        title: AppBrand.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: AuthGate(
          backend: bootstrap.backend,
          statusLabel: bootstrap.statusLabel,
          statusMessage: bootstrap.statusMessage,
        ),
      ),
    );
  }
}
