import UIKit

<<<<<<< HEAD
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QiuzResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var staticService: StatisticService!
    var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let questionAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var questionResult: Bool = true
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        staticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = self.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
=======
final class MovieQuizPresenter {
    let questionAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var questionResult: Bool = true
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
>>>>>>> parent of 2e25fe7 (Финальный проект 7 спринт)
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func handleAnswer(isYes: Bool) {
        if questionResult {
            questionResult = false
            guard let currentQuestion = currentQuestion else {
                return
            }
            let giveAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
        }
    }
    
    func yesButtonClicked() {
        handleAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        handleAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        self.currentQuestion = question
        let viewModel = self.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.staticService.store(correct: correctAnswers, total: self.questionAmount)
            let bestGameRecord = viewController?.staticService.bestGame
            let accuracyPercentage = Double(correctAnswers) / Double(self.questionAmount) * 100
            let text = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных игр: \(String(describing: viewController?.staticService.gamesCount))\nРекорд: \(String(describing: bestGameRecord?.correct))/10 (\(String(describing: bestGameRecord?.date.dateTimeString)))\nСредняя точность: \(String(format: "%.2f", accuracyPercentage))%"
            let viewModel = QiuzResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
}
