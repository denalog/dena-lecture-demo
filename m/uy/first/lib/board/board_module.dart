import 'package:first/board/presentation/providers/board_create_provider.dart';
import 'package:first/board/presentation/providers/board_list_provider.dart';
import 'package:first/board/presentation/providers/board_read_provider.dart';
import 'package:first/board/presentation/ui/board_create_page.dart';
import 'package:first/board/presentation/ui/board_list_page.dart';
import 'package:first/board/presentation/ui/board_read_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'domain/usecases/create/create_board_use_case_impl.dart';
import 'domain/usecases/list/list_board_use_case_impl.dart';
import 'domain/usecases/read/read_board_usecase_impl.dart';
import 'infrasturctures/data_sources/board_remote_data_source.dart';
import 'infrasturctures/repository/board_repository_impl.dart';

class BoardModule {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static final boardRemoteDataSource = BoardRemoteDataSource(baseUrl);
  static final boardRepository = BoardRepositoryImpl(boardRemoteDataSource);

  static final listBoardUseCase = ListBoardUseCaseImpl(boardRepository);
  static final createBoardUseCase = CreateBoardUseCaseImpl(boardRepository);
  static final readBoardUseCase = ReadBoardUseCaseImpl(boardRepository);

  static List<SingleChildWidget> provideCommonProviders () {
    return [
      Provider(create: (_) => listBoardUseCase),
      Provider(create: (_) => createBoardUseCase),
      Provider(create: (_) => readBoardUseCase)
    ];
  }

  static Widget provideBoardListPage() {
    return MultiProvider(
      providers: [
        ...provideCommonProviders(),
        ChangeNotifierProvider(
          create: (_) =>
              BoardListProvider(listBoardUseCase: listBoardUseCase),
        )
      ],
      child: BoardListPage(),
    );
  }

  static Widget provideBoardCreatePage() {
    return MultiProvider(
      providers: [
        ...provideCommonProviders(),
        ChangeNotifierProvider(
            create: (_) =>
                BoardCreateProvider(createBoardUseCase: createBoardUseCase)
        )
      ],
      child: BoardCreatePage(),
    );
  }

  static Widget provideBoardReadPage(int id) {
    return MultiProvider(
      providers: [
        ...provideCommonProviders(),
        ChangeNotifierProvider(
            create: (_) =>
            BoardReadProvider(
                readBoardUseCase: readBoardUseCase,
                boardId: id
            )..fetchBoard()
        ),
      ],
      child: BoardReadPage(),
    );
  }
}