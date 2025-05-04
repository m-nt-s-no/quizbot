Rails.application.routes.draw do

  # Routes for the Quiz resource:

  # CREATE
  post("/insert_quiz", { :controller => "quizzes", :action => "create" })
          
  # READ
  get("/quizzes", { :controller => "quizzes", :action => "index" })
  
  get("/quizzes/:path_id", { :controller => "quizzes", :action => "show" })
  
  # UPDATE
  
  post("/modify_quiz/:path_id", { :controller => "quizzes", :action => "update" })
  
  # DELETE
  get("/delete_quiz/:path_id", { :controller => "quizzes", :action => "destroy" })

  #------------------------------

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  
end
