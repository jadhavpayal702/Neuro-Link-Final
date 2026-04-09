/// Vocal Mode learning courses — single source of truth for titles and lesson scripts.
class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.keywords,
    required this.welcomeScript,
    required this.lessonSteps,
  });

  final String id;
  final String title;
  final List<String> keywords;
  final String welcomeScript;
  final List<String> lessonSteps;

  static const List<CourseModel> vocalCourses = [
    CourseModel(
      id: 'english_speaking',
      title: 'English Speaking',
      keywords: ['english', 'speaking', 'english speaking', 'spoken english'],
      welcomeScript:
          'Welcome to the English Speaking course. We will practice clear pronunciation and short dialogues step by step.',
      lessonSteps: [
        'Step one: Greet clearly. Say hello, good morning, or good afternoon with a steady pace.',
        'Step two: Introduce yourself in one sentence. Say your name and one thing you enjoy.',
        'Step three: Ask a simple question. For example, how are you today?',
        'Step four: Listen for key words in replies and respond with a short sentence.',
      ],
    ),
    CourseModel(
      id: 'basic_computer',
      title: 'Basic Computer Skills',
      keywords: ['computer', 'basic computer', 'pc', 'desktop', 'keyboard', 'mouse'],
      welcomeScript:
          'Welcome to Basic Computer Skills. We will cover the keyboard, mouse, files, and safe shutdown.',
      lessonSteps: [
        'Step one: The keyboard types letters and numbers. Find the space bar and enter key.',
        'Step two: The mouse moves the pointer. Left click selects, right click opens extra options.',
        'Step three: Files live in folders. Think of a folder like a drawer that holds documents.',
        'Step four: Always shut down from the system menu instead of unplugging power.',
      ],
    ),
    CourseModel(
      id: 'daily_life',
      title: 'Daily Life Skills',
      keywords: ['daily', 'life', 'daily life', 'everyday', 'routine'],
      welcomeScript:
          'Welcome to Daily Life Skills. We will practice planning, safety, and communication for everyday tasks.',
      lessonSteps: [
        'Step one: Make a short plan for today with three tasks in order.',
        'Step two: For safety, confirm exits and emergency contacts before leaving home.',
        'Step three: When shopping, ask for help clearly and confirm prices aloud.',
        'Step four: End the day by reviewing what went well and one thing to improve tomorrow.',
      ],
    ),
    CourseModel(
      id: 'coding_basics',
      title: 'Coding Basics',
      keywords: ['coding', 'code', 'programming', 'developer', 'script'],
      welcomeScript:
          'Welcome to Coding Basics. We will learn what code is, how programs run, and how to read simple instructions.',
      lessonSteps: [
        'Step one: Code is text that tells a computer what to do, step by step.',
        'Step two: A program runs from top to bottom unless loops or conditions change the path.',
        'Step three: Variables store values like numbers or words for later use.',
        'Step four: Practice by describing a tiny task in plain English, then break it into ordered steps.',
      ],
    ),
  ];

  static CourseModel? matchBySpeech(String lower) {
    for (final c in vocalCourses) {
      for (final k in c.keywords) {
        if (lower.contains(k)) return c;
      }
      if (lower.contains(c.title.toLowerCase())) return c;
    }
    return null;
  }
}
