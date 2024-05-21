import UIKit

<<<<<<< HEAD
final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
=======
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let presenter = MovieQuizPresenter()
    
>>>>>>> parent of 2e25fe7 (Финальный проект 7 спринт)
    // MARK: - Outlet
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var counterLabel: UILabel!
    // MARK: - Variable
    
    var staticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        staticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.questionResult = true
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            staticService.store(correct: presenter.correctAnswers, total: presenter.questionAmount)
            let bestGameRecord = staticService.bestGame
            let accuracyPercentage = Double(presenter.correctAnswers) / Double(presenter.questionAmount) * 100
            let text = "Ваш результат: \(presenter.correctAnswers)/10\nКоличество сыгранных игр: \(staticService.gamesCount)\nРекорд: \(bestGameRecord.correct)/10 (\(bestGameRecord.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", accuracyPercentage))%"
            let viewModel = QiuzResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            
            presenter.questionFactory?.requestNextQuestion()
        }
    }
    
    func show(quiz result: QiuzResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {
            self.presenter.currentQuestionIndex = 0
            self.presenter.correctAnswers = 0
            self.presenter.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.presentAlert(from: self, with: alertModel)
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
            
            self.presenter.resetQuestionIndex()
            self.presenter.correctAnswers = 0
            
            self.presenter.questionFactory?.requestNextQuestion()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.presentAlert(from: self, with: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        presenter.questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // MARK: - IBAction
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
}



