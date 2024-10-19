import 'package:bloc/bloc.dart';
import 'package:list_with_bloc/model/post.dart';

class PostEvent {}

abstract class PostState {}

class PostUnitialized extends PostState {}

class PostLoaded extends PostState {
  List<Post> posts;
  bool hasReachedMax;

  PostLoaded({
    this.posts = const <Post>[],
    this.hasReachedMax = false,
  });

  PostLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostUnitialized()) {
    on<PostEvent>((event, emit) async {
      List<Post> posts;

      if (state is PostUnitialized) {
        posts = await Post.connectToApi(0, 10);
        emit(PostLoaded(posts: posts, hasReachedMax: false));
      } else {
        PostLoaded postLoaded = state as PostLoaded;

        posts = await Post.connectToApi(postLoaded.posts.length, 10);

        emit(posts.isEmpty
            ? postLoaded.copyWith(hasReachedMax: true)
            : postLoaded.copyWith(
                posts: postLoaded.posts + posts, hasReachedMax: false));
      }
    });
  }
}
