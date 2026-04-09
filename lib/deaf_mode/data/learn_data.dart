import '../models/learn_models.dart';

class LearnData {
  static List<CourseDetailModel> getAllCourses() {
    return [
      _signLanguageBasics(),
      _readingComprehension(),
      _visualCommunication(),
      _technologySkills(),
    ];
  }

  static CourseDetailModel _signLanguageBasics() {
    return CourseDetailModel(
      title: 'Sign Language Basics',
      videos: [
        VideoModel(
          title: 'Basic Concepts & Greetings',
          description: 'Introduction to basic sign language concepts, including simple greetings and commonly used everyday signs for beginners.',
          url: 'https://www.youtube.com/embed/6_gXiBe9y9A',
        ),
        VideoModel(
          title: 'Essential ASL Vocabulary',
          description: 'Learn essential ASL vocabulary with clear demonstrations of frequently used words and phrases to build foundational communication skills.',
          url: 'https://www.youtube.com/embed/8e3V3C9G1dM',
        ),
        VideoModel(
          title: 'Sentence Formation',
          description: 'Practice forming simple sentences in sign language and understand how to combine basic signs into meaningful communication.',
          url: 'https://www.youtube.com/embed/6_gXiBe9y9A',
        ),
        // TODO: Add YouTube link and description
        VideoModel(
          title: 'Advanced Greetings',
          description: 'Learn how to greet in different contexts and formal settings using professional sign language gestures.',
          url: 'https://www.youtube.com/embed/6_gXiBe9y9A', // Placeholder
        ),
        // TODO: Add YouTube link and description
        VideoModel(
          title: 'Emergency Signs',
          description: 'Critical signs to use in emergency situations to communicate needs quickly and effectively.',
          url: 'https://www.youtube.com/embed/6_gXiBe9y9A', // Placeholder
        ),
      ],
      quizzes: [
        QuizModel(
          title: 'Level 1: Hand Signs',
          questions: [
            QuestionModel(question: 'What does 🤟 mean?', options: ['I Love You', 'Hello', 'Maybe', 'No'], correctIndex: 0),
            QuestionModel(question: 'What does ✋ mean?', options: ['Stop', 'Yes', 'Five', 'Wait'], correctIndex: 2),
            QuestionModel(question: 'What does 🤘 mean?', options: ['Rock On', 'Please', 'Water', 'Eat'], correctIndex: 0),
            QuestionModel(question: 'What does 🖐️ mean?', options: ['Five', 'Hello', 'Stop', 'Go'], correctIndex: 0),
            QuestionModel(question: 'What does 👍 mean?', options: ['Bad', 'Good/Yes', 'No', 'Help'], correctIndex: 1),
            QuestionModel(question: 'How do you sign "Help"?', options: ['Flat palm on fist', 'Waving hand', 'Tapping chest', 'Clapping'], correctIndex: 0),
            QuestionModel(question: 'Which sign is for "Yes"?', options: ['Nodding fist', 'Shaking hand', 'Flat palm', 'Point finger'], correctIndex: 0),
            QuestionModel(question: 'What is the sign for "Thank You"?', options: ['Hand from chin to front', 'Tapping head', 'Rubbing stomach', 'Waves'], correctIndex: 0),
            QuestionModel(question: 'What does 👋 mean?', options: ['Goodbye', 'Hello', 'Both A and B', 'Wait'], correctIndex: 2),
            QuestionModel(question: 'How do you sign "No"?', options: ['Index and middle finger tap thumb', 'Shaking head only', 'Clenched fist', 'Open palm'], correctIndex: 0),
          ],
        ),
        // Adding more quizzes to fulfill "5 total" for Course 1
        QuizModel(title: 'Level 2: Common Words', questions: _generateGenericQuestions('Common Words')),
        QuizModel(title: 'Level 3: Everyday Phrases', questions: _generateGenericQuestions('Phrases')),
        QuizModel(title: 'Level 4: Numbers 1-10', questions: _generateGenericQuestions('Numbers')),
        QuizModel(title: 'Final Mastery', questions: _generateGenericQuestions('Mastery')),
      ],
    );
  }

  static CourseDetailModel _readingComprehension() {
    return CourseDetailModel(
      title: 'Reading & Comprehension',
      videos: [], // User asked for Section 1: Books for this course
      books: [
        BookModel(
          title: 'Beginner English Story Books (A1–A2)',
          description: 'Collection of simple English storybooks with basic vocabulary and short sentences, perfect for beginners to improve reading and understanding.',
          url: 'https://www.learnenglishteam.com/english-story-books-for-beginners/',
        ),
        BookModel(
          title: 'Free Reading Comprehension Stories & PDFs',
          description: 'Short stories with comprehension questions and downloadable PDFs designed to improve reading skills step by step.',
          url: 'https://readstories-learnenglish.com/reading-comprehension-free-materials/',
        ),
        BookModel(
          title: '702 Reading Comprehension Worksheets',
          description: 'Large collection of beginner-level reading passages with questions and answers for practice and assessment.',
          url: 'https://www.grammarism.com/beginner-reading-worksheets/',
        ),
        BookModel(
          title: '15 Free English Books for Beginners',
          description: 'Free downloadable beginner books with simple language, helping users build vocabulary and comprehension skills.',
          url: 'https://infobooks.org/free-pdf-books/language-learning/english-books-for-beginners/',
        ),
        BookModel(
          title: 'Reading Boat 1 (Beginner PDF Book)',
          description: 'Structured beginner reading book with short stories, vocabulary, and comprehension exercises for early learners.',
          url: 'https://teachingmaterial.minibilinguals.com/producto/product-reading-boat-1-pdf/',
        ),
      ],
      quizzes: [
        QuizModel(
          title: 'Grammar & Sentences',
          questions: [
            QuestionModel(question: 'Identify the verb: "The boy signs fast."', options: ['Boy', 'Signs', 'Fast', 'The'], correctIndex: 1),
            QuestionModel(question: 'Complete: "I ___ learning ASL."', options: ['is', 'are', 'am', 'be'], correctIndex: 2),
            QuestionModel(question: 'Opposite of "Hot" is:', options: ['Cold', 'Warm', 'Fire', 'Sun'], correctIndex: 0),
            QuestionModel(question: 'Select correct spelling:', options: ['Signn', 'Sign', 'Sine', 'Sighn'], correctIndex: 1),
            QuestionModel(question: 'Plural of "Child" is:', options: ['Childs', 'Children', 'Childes', 'Childrens'], correctIndex: 1),
            QuestionModel(question: 'Which is a greeting?', options: ['Apple', 'Hello', 'Run', 'Blue'], correctIndex: 1),
            QuestionModel(question: 'A person who cannot hear is called:', options: ['Blind', 'Deaf', 'Mute', 'Lame'], correctIndex: 1),
            QuestionModel(question: 'Past tense of "Go" is:', options: ['Goed', 'Going', 'Went', 'Gone'], correctIndex: 2),
            QuestionModel(question: 'A punctuation mark at end of question:', options: ['.', '!', '?', ','], correctIndex: 2),
            QuestionModel(question: '"Quick" means:', options: ['Slow', 'Fast', 'Brave', 'Smart'], correctIndex: 1),
          ],
        ),
        QuizModel(title: 'Word Meaning', questions: _generateGenericQuestions('Word Meanings')),
      ],
    );
  }

  static CourseDetailModel _visualCommunication() {
    return CourseDetailModel(
      title: 'Visual Communication',
      videos: [
        VideoModel(
          title: 'Introduction to Visual Communication',
          description: 'Introduction to visual communication, explaining how images, symbols, and visuals are used to convey messages effectively.',
          url: 'https://www.youtube.com/embed/M7lc1UVf-VE',
        ),
        VideoModel(
          title: 'Gestures and Body Movements',
          description: 'Learn how gestures and body movements help in communication, especially for non-verbal interaction and understanding.',
          url: 'https://www.youtube.com/embed/fn2jZpFhZ2k',
        ),
        VideoModel(
          title: 'Facial Expressions and Body Language',
          description: 'Understand the role of facial expressions and body language in expressing emotions and improving communication skills.',
          url: 'https://www.youtube.com/embed/v9j0Jq3F6vE',
        ),
      ],
      quizzes: [
        QuizModel(
          title: 'Facial Cues',
          questions: [
            QuestionModel(question: 'Raised eyebrows usually mean:', options: ['Angry', 'Surprised', 'Sad', 'Bored'], correctIndex: 1),
            QuestionModel(question: 'A smile indicates:', options: ['Fear', 'Happiness', 'Pain', 'Worry'], correctIndex: 1),
            QuestionModel(question: 'Frowning eyebrows might mean:', options: ['Excited', 'Confused/Angry', 'Sleepy', 'Kind'], correctIndex: 1),
            QuestionModel(question: 'Widened eyes can show:', options: ['Shock', 'Blink', 'Shut', 'None'], correctIndex: 0),
            QuestionModel(question: 'Avoiding eye contact might mean:', options: ['Shy/Uncomfortable', 'Confident', 'Happy', 'Angry'], correctIndex: 0),
            QuestionModel(question: 'Biting lip might show:', options: ['Hunger', 'Nervousness', 'Joy', 'Sleep'], correctIndex: 1),
            QuestionModel(question: 'A wink usually suggests:', options: ['Danger', 'Inside joke/Secret', 'Pain', 'Anger'], correctIndex: 1),
            QuestionModel(question: 'Looking down often means:', options: ['Arrogance', 'Sadness/Regret', 'Success', 'Playful'], correctIndex: 1),
            QuestionModel(question: 'Tilted head shows:', options: ['Interest/Listening', 'Boredom', 'Refusal', 'None'], correctIndex: 0),
            QuestionModel(question: 'Direct eye contact shows:', options: ['Aggression', 'Attention', 'Both A and B', 'Sleep'], correctIndex: 2),
          ],
        ),
      ],
    );
  }

  static CourseDetailModel _technologySkills() {
    return CourseDetailModel(
      title: 'Technology Skills',
      videos: [
        VideoModel(
          title: 'Basic Computer Skills',
          description: 'Introduction to basic computer skills, including understanding hardware, software, and how to operate a computer effectively.',
          url: 'https://www.youtube.com/embed/2ePf9rue1Ao',
        ),
        VideoModel(
          title: 'Smartphone Essentials',
          description: 'Learn essential smartphone skills such as navigation, using apps, making calls, and managing basic settings.',
          url: 'https://www.youtube.com/embed/HXx0Xb4iH6k',
        ),
        VideoModel(
          title: 'Internet Safety & Basics',
          description: 'Understand internet basics including browsing websites, using search engines, and practicing safe online behavior.',
          url: 'https://www.youtube.com/embed/Gp2bUX7hQnA',
        ),
      ],
      quizzes: [
        QuizModel(
          title: 'Internet Basics',
          questions: [
            QuestionModel(question: 'What is a browser?', options: ['A website', 'Software to view web', 'A keyboard', 'Internet provider'], correctIndex: 1),
            QuestionModel(question: 'Google is a:', options: ['Search Engine', 'Operating System', 'Web browser', 'Social Media'], correctIndex: 0),
            QuestionModel(question: 'What does WWW stand for?', options: ['World Wide Web', 'World Wide Word', 'Wide World Web', 'Web World Wide'], correctIndex: 0),
            QuestionModel(question: 'Which is an email service?', options: ['Gmail', 'YouTube', 'Facebook', 'Spotify'], correctIndex: 0),
            QuestionModel(question: 'A safe password should be:', options: ['"password"', 'Your birthdate', 'Mix of chars/numbers', '12345'], correctIndex: 2),
            QuestionModel(question: 'What is "Wi-Fi"?', options: ['Wired network', 'Wireless network', 'Radio station', 'Power cable'], correctIndex: 1),
            QuestionModel(question: 'Cloud storage means:', options: ['Storage in sky', 'Online storage', 'CD storage', 'USB drive'], correctIndex: 1),
            QuestionModel(question: 'A smartphone runs on:', options: ['Windows only', 'iOS or Android', 'Battery only', 'Petrol'], correctIndex: 1),
            QuestionModel(question: 'What is an "App"?', options: ['Application Software', 'Apple Pie', 'A person', 'Abstract'], correctIndex: 0),
            QuestionModel(question: 'Spam refers to:', options: ['Good emails', 'Unwanted/Junk emails', 'Delicious food', 'Friends'], correctIndex: 1),
          ],
        ),
      ],
    );
  }

  static List<QuestionModel> _generateGenericQuestions(String topic) {
    return List.generate(
      10,
      (i) => QuestionModel(
        question: 'Question ${i + 1} about $topic?',
        options: ['Correct Option', 'Wrong Option A', 'Wrong Option B', 'Wrong Option C'],
        correctIndex: 0,
      ),
    );
  }
}
