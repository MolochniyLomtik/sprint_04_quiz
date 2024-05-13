import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let questionAmount: Int = 10
    // MARK: - Outlet
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    // MARK: - Variable
    private var questionFactory: QuestionFactoryProtocol?
    
    private var staticService: StatisticService = StatisticServiceImplementation()
    
    private var currentQuestion: QuizQuestion?
    
    private var correctAnswers = 0
    
    private var currentQuestionIndex = 0
    
    private var questionResult: Bool = true
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        staticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.questionResult = true
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            staticService.store(correct: correctAnswers, total: questionAmount)
            let bestGameRecord = staticService.bestGame
            let accuracyPercentage = Double(correctAnswers) / Double(questionAmount) * 100
            let text = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных игр: \(staticService.gamesCount)\nРекорд: \(bestGameRecord.correct)/10 (\(bestGameRecord.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", accuracyPercentage))%"
            let viewModel = QiuzResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QiuzResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.presentAlert(from: self, with: alertModel)
    }
    
    private func handleAnswer(isYes: Bool) {
        if questionResult {
            questionResult = false
            guard let currentQuestion = currentQuestion else {
                return
            }
            let giveAnswer = isYes
            
            showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        showLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.presentAlert(from: self, with: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: true)
    }
}



