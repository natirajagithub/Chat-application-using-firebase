import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External (Firebase instances)
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Feature - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(firebaseAuth: sl()));

  // Feature - Chat
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(firestore: sl()));
  
  // Feature - Notifications
}

