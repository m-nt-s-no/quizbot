class QuizzesController < ApplicationController
  def index
    matching_quizzes = Quiz.all

    @list_of_quizzes = matching_quizzes.order({ :created_at => :desc })

    render({ :template => "quizzes/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_quizzes = Quiz.where({ :id => the_id })

    @the_quiz = matching_quizzes.at(0)

    render({ :template => "quizzes/show" })
  end

  def create
    the_quiz = Quiz.new
    the_quiz.topic = params.fetch("query_topic")

    if the_quiz.valid?
      the_quiz.save
      redirect_to("/quizzes", { :notice => "Quiz created successfully." })
    else
      redirect_to("/quizzes", { :alert => the_quiz.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_quiz = Quiz.where({ :id => the_id }).at(0)

    the_quiz.topic = params.fetch("query_topic")

    if the_quiz.valid?
      the_quiz.save
      redirect_to("/quizzes/#{the_quiz.id}", { :notice => "Quiz updated successfully."} )
    else
      redirect_to("/quizzes/#{the_quiz.id}", { :alert => the_quiz.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_quiz = Quiz.where({ :id => the_id }).at(0)

    the_quiz.destroy

    redirect_to("/quizzes", { :notice => "Quiz deleted successfully."} )
  end
end
