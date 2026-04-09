class CourseDetailModel {
  final String title;
  final List<VideoModel> videos;
  final List<QuizModel> quizzes;
  final List<BookModel>? books;

  CourseDetailModel({
    required this.title,
    required this.videos,
    required this.quizzes,
    this.books,
  });
}

class VideoModel {
  final String title;
  final String description;
  final String url;

  VideoModel({
    required this.title,
    required this.description,
    required this.url,
  });
}

class BookModel {
  final String title;
  final String description;
  final String url;

  BookModel({
    required this.title,
    required this.description,
    required this.url,
  });
}

class QuizModel {
  final String title;
  final List<QuestionModel> questions;

  QuizModel({
    required this.title,
    required this.questions,
  });
}

class QuestionModel {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}
