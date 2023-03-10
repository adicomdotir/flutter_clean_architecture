import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_clean_arch/core/states/data_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_clean_arch/core/error/failure.dart' as error;
import 'package:flutter_clean_arch/core/no_params.dart';
import 'package:flutter_clean_arch/domain/entities/user.dart';
import 'package:flutter_clean_arch/presentation/bloc/users_cubit.dart';

import '../../mocks/generate_mocks.mocks.dart';
import '../../mocks/mock_users.dart';

typedef Users = List<User>;

void main() {
  late UsersCubit userCubit;
  late MockGetUsers mockGetUsers;

  setUp(() {
    mockGetUsers = MockGetUsers();
    userCubit = UsersCubit(mockGetUsers);
  });

  group('UserCubit', () {
    blocTest<UsersCubit, DataState<Users>>(
      'should emit empty if nothing happened',
      build: () => userCubit,
      expect: () => [],
    );

    blocTest<UsersCubit, DataState<Users>>(
      'should emit [InProgress] when action is started',
      build: () => userCubit,
      act: (cubit) => cubit.fetchUsers(),
      expect: () => [DataState<Users>.inProgress()],
    );

    blocTest<UsersCubit, DataState<Users>>(
      'should emit [Failure] when action is not successful',
      setUp: () {
        when(mockGetUsers.call(const NoParams())).thenAnswer(
          (_) async => Left(error.ServerFailure()),
        );
      },
      build: () => userCubit,
      act: (cubit) => cubit.fetchUsers(),
      expect: () => [
        DataState<Users>.inProgress(),
        DataState<Users>.failure(),
      ],
    );

    blocTest<UsersCubit, DataState<Users>>(
      'should emit [Empty] if there is no user',
      setUp: () {
        when(mockGetUsers.call(const NoParams())).thenAnswer(
          (_) async => const Right([]),
        );
      },
      build: () => userCubit,
      act: (cubit) => cubit.fetchUsers(),
      expect: () => [
        DataState<Users>.inProgress(),
        DataState<Users>.empty(),
      ],
    );

    blocTest<UsersCubit, DataState<Users>>(
      'should emit [Success] with the list of users when action is  successful',
      setUp: () {
        when(mockGetUsers.call(const NoParams())).thenAnswer(
          (_) async => const Right(users),
        );
      },
      build: () => userCubit,
      act: (cubit) => cubit.fetchUsers(),
      expect: () => [
        DataState<Users>.inProgress(),
        DataState<Users>.success(users),
      ],
    );
  });
}
