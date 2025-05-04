class MessagesController < ApplicationController
  def index
    matching_messages = Message.all

    @list_of_messages = matching_messages.order({ :created_at => :desc })

    render({ :template => "messages/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_messages = Message.where({ :id => the_id })

    @the_message = matching_messages.at(0)

    render({ :template => "messages/show" })
  end

  def create
    the_message = Message.new
    the_message.quiz_id = params.fetch("query_quiz_id")
    the_message.body = params.fetch("query_body")
    the_message.role = "user"

    if the_message.valid?
      the_message.save

      #Generate next AI assistant message, save it
      require "openai"
      require "dotenv/load"

      client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      message_list = []
      the_message.quiz.messages.order(:created_at).each do |msg|
        msg_hash = {
          "role" => "#{msg.role}",
          "content" => "#{msg.body}"
        }
        message_list.push(msg_hash)
      end

      #Call API to get assistant message from ChatGPT
      api_response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: message_list
        }
      )
      assistant_msg_content = api_response.fetch("choices").at(0).fetch("message").fetch("content")

      #Save assistant msg in quiz's messages
      assistant_msg = Message.new
      assistant_msg.quiz_id = the_message.quiz_id
      assistant_msg.role = "assistant"
      assistant_msg.body = assistant_msg_content
      assistant_msg.save

      redirect_to("/quizzes/#{the_message.quiz_id}", { :notice => "Message created successfully." })
    else
      redirect_to("/quizzes/#{the_message.quiz_id}", { :alert => the_message.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_message = Message.where({ :id => the_id }).at(0)

    the_message.quiz_id = params.fetch("query_quiz_id")
    the_message.body = params.fetch("query_body")
    the_message.role = params.fetch("query_role")

    if the_message.valid?
      the_message.save
      redirect_to("/messages/#{the_message.id}", { :notice => "Message updated successfully."} )
    else
      redirect_to("/messages/#{the_message.id}", { :alert => the_message.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_message = Message.where({ :id => the_id }).at(0)

    the_message.destroy

    redirect_to("/messages", { :notice => "Message deleted successfully."} )
  end
end
