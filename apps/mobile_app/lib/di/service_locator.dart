import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:blog_data/blog_data.dart';
import 'package:blog_domain/blog_domain.dart';
import 'package:blog_presentation/blog_presentation.dart';
import 'package:core_data/core_data.dart';
import 'package:logger_service/logger_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final LoggerService loggerService;
  late final NetworkClient networkClient;
  late final AuthRepository authRepository;
  late final LoginUser loginUserUseCase;
  late final AuthController authController;

  late final BlogRepository blogRepository;
  late final GetBlogPosts getBlogPostsUseCase;
  late final BlogController blogController;

  void setup() {
    loggerService = ConsoleLoggerService(prefix: 'MOBILE_APP');

    networkClient = MockNetworkClient(
      logger: loggerService,
      postHandler: (path, body) {
        if (path.contains('/auth/login')) {
          return {
            'id': 'usr_100',
            'email': body?['email'] ?? 'user@example.com',
            'name': 'Jules Developer',
            'token': 'mock_jwt_token_12345',
          };
        }
        return {};
      },
      getHandler: (path, queryParameters) {
        if (path.contains('/posts')) {
          return {
            'items': [
              {
                'id': 'post_1',
                'title': 'Modular Monorepo in Dart',
                'content': 'Learn how to construct LEGO-like Dart packages with native workspaces.',
                'author': 'Jules',
                'publishedAtIso': '2026-02-01T12:00:00Z',
              },
              {
                'id': 'post_2',
                'title': 'SOLID Clean Architecture',
                'content': 'Decouple presentation, domain, and data layers cleanly.',
                'author': 'Jules',
                'publishedAtIso': '2026-02-15T15:30:00Z',
              },
            ],
          };
        }
        return {};
      },
    );

    // Auth Module Wiring with Local Cache
    final authRemoteDataSource = AuthRemoteDataSourceImpl(networkClient);
    final authLocalDataSource = InMemoryAuthLocalDataSourceImpl();
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    loginUserUseCase = LoginUser(authRepository);
    authController = AuthController(loginUserUseCase);

    // Blog Module Wiring
    blogRepository = BlogRepositoryImpl(networkClient);
    getBlogPostsUseCase = GetBlogPosts(blogRepository);
    blogController = BlogController(getBlogPostsUseCase);
  }
}
