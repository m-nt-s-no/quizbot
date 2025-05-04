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
    @the_quiz = Quiz.new
    @the_quiz.topic = params.fetch("query_topic")

    if @the_quiz.valid?
      @the_quiz.save

      #Create system message
      system_msg = Message.new
      system_msg.quiz_id = @the_quiz.id
      system_msg.role = "system"
      system_msg.body = "You are a #{@the_quiz.topic} tutor. 
          Ask the user five questions to assess their #{@the_quiz.topic}
          proficiency. Start with an easy question. After each answer,
          increase or decrease  the difficulty of the next question
          based on how well the user answered. 
          
          In the end, provide a score between 0 and 10."
      system_msg.save

      #Create first user message
      first_user_msg = Message.new
      first_user_msg.quiz_id = @the_quiz.id
      first_user_msg.role = "user"
      first_user_msg.body = "Can you assess my #{@the_quiz.topic} proficiency?"
      first_user_msg.save

      #Call API to get first assistant message
      require "openai"
      require "dotenv/load"

      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      #Prepare array of previous messages
      message_list = [
        {
          "role" => "#{system_msg.role}",
          "content" => "#{system_msg.body}"
        },
        {
          "role" => "#{first_user_msg.role}",
          "content" => "#{first_user_msg.body}"
        }
      ]

      #Call API to get assistant message from ChatGPT
      api_response = client.chat(
        parameters: {
          model: "gpt-4o",
          messages: message_list
        }
      )
      assistant_msg_content = api_response.fetch("choices").at(0).fetch("message").fetch("content")

      #Save assistant msg in quiz's messages
      assistant_msg = Message.new
      assistant_msg.quiz_id = @the_quiz.id
      assistant_msg.role = "assistant"
      assistant_msg.body = assistant_msg_content
      assistant_msg.save

      redirect_to("/quizzes/#{@the_quiz.id}", { :notice => "Quiz created successfully." })
    else
      redirect_to("/quizzes/#{@the_quiz.id}", { :alert => the_quiz.errors.full_messages.to_sentence })
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
