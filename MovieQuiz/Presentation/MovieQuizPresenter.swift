import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var questionResult: Bool = true
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
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
    
    func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        handleAnswer(isYes: false)
    }
}
