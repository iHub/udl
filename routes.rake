                                       Prefix Verb   URI Pattern                                                                                        Controller#Action
                         facebook_posts_index GET    /facebook_posts/index(.:format)                                                                    facebook_posts#index
                          facebook_posts_show GET    /facebook_posts/show(.:format)                                                                     facebook_posts#show
                        facebook_posts_search POST   /facebook_posts/search(.:format)                                                                   facebook_posts#search
                            csv_import_import GET    /csv_import/import(.:format)                                                                       csv_import#import
                                   logs_index GET    /logs/index(.:format)                                                                              logs#index
                                        users GET    /users(.:format)                                                                                   users#index
                                              POST   /users(.:format)                                                                                   users#create
                                     new_user GET    /users/new(.:format)                                                                               users#new
                                    edit_user GET    /users/:id/edit(.:format)                                                                          users#edit
                                         user GET    /users/:id(.:format)                                                                               users#show
                                              PATCH  /users/:id(.:format)                                                                               users#update
                                              PUT    /users/:id(.:format)                                                                               users#update
                                              DELETE /users/:id(.:format)                                                                               users#destroy
                                     sessions POST   /sessions(.:format)                                                                                sessions#create
                                  new_session GET    /sessions/new(.:format)                                                                            sessions#new
                                      session DELETE /sessions/:id(.:format)                                                                            sessions#destroy
                                 app_settings GET    /app_settings(.:format)                                                                            app_settings#index
                                              POST   /app_settings(.:format)                                                                            app_settings#create
                              new_app_setting GET    /app_settings/new(.:format)                                                                        app_settings#new
                             edit_app_setting GET    /app_settings/:id/edit(.:format)                                                                   app_settings#edit
                                  app_setting GET    /app_settings/:id(.:format)                                                                        app_settings#show
                                              PATCH  /app_settings/:id(.:format)                                                                        app_settings#update
                                              PUT    /app_settings/:id(.:format)                                                                        app_settings#update
                                              DELETE /app_settings/:id(.:format)                                                                        app_settings#destroy
    scrape_session_scrape_page_facebook_posts GET    /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts(.:format)          facebook_posts#index
                                              POST   /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts(.:format)          facebook_posts#create
 new_scrape_session_scrape_page_facebook_post GET    /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/new(.:format)      facebook_posts#new
edit_scrape_session_scrape_page_facebook_post GET    /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/:id/edit(.:format) facebook_posts#edit
     scrape_session_scrape_page_facebook_post GET    /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/:id(.:format)      facebook_posts#show
                                              PATCH  /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/:id(.:format)      facebook_posts#update
                                              PUT    /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/:id(.:format)      facebook_posts#update
                                              DELETE /scrape_sessions/:scrape_session_id/scrape_pages/:scrape_page_id/facebook_posts/:id(.:format)      facebook_posts#destroy
                  scrape_session_scrape_pages GET    /scrape_sessions/:scrape_session_id/scrape_pages(.:format)                                         scrape_pages#index
                                              POST   /scrape_sessions/:scrape_session_id/scrape_pages(.:format)                                         scrape_pages#create
               new_scrape_session_scrape_page GET    /scrape_sessions/:scrape_session_id/scrape_pages/new(.:format)                                     scrape_pages#new
              edit_scrape_session_scrape_page GET    /scrape_sessions/:scrape_session_id/scrape_pages/:id/edit(.:format)                                scrape_pages#edit
                   scrape_session_scrape_page GET    /scrape_sessions/:scrape_session_id/scrape_pages/:id(.:format)                                     scrape_pages#show
                                              PATCH  /scrape_sessions/:scrape_session_id/scrape_pages/:id(.:format)                                     scrape_pages#update
                                              PUT    /scrape_sessions/:scrape_session_id/scrape_pages/:id(.:format)                                     scrape_pages#update
                                              DELETE /scrape_sessions/:scrape_session_id/scrape_pages/:id(.:format)                                     scrape_pages#destroy
              scrape_session_question_answers GET    /scrape_sessions/:scrape_session_id/questions/:question_id/answers(.:format)                       answers#index
                                              POST   /scrape_sessions/:scrape_session_id/questions/:question_id/answers(.:format)                       answers#create
           new_scrape_session_question_answer GET    /scrape_sessions/:scrape_session_id/questions/:question_id/answers/new(.:format)                   answers#new
          edit_scrape_session_question_answer GET    /scrape_sessions/:scrape_session_id/questions/:question_id/answers/:id/edit(.:format)              answers#edit
               scrape_session_question_answer GET    /scrape_sessions/:scrape_session_id/questions/:question_id/answers/:id(.:format)                   answers#show
                                              PATCH  /scrape_sessions/:scrape_session_id/questions/:question_id/answers/:id(.:format)                   answers#update
                                              PUT    /scrape_sessions/:scrape_session_id/questions/:question_id/answers/:id(.:format)                   answers#update
                                              DELETE /scrape_sessions/:scrape_session_id/questions/:question_id/answers/:id(.:format)                   answers#destroy
                     scrape_session_questions GET    /scrape_sessions/:scrape_session_id/questions(.:format)                                            questions#index
                                              POST   /scrape_sessions/:scrape_session_id/questions(.:format)                                            questions#create
                  new_scrape_session_question GET    /scrape_sessions/:scrape_session_id/questions/new(.:format)                                        questions#new
                 edit_scrape_session_question GET    /scrape_sessions/:scrape_session_id/questions/:id/edit(.:format)                                   questions#edit
                      scrape_session_question GET    /scrape_sessions/:scrape_session_id/questions/:id(.:format)                                        questions#show
                                              PATCH  /scrape_sessions/:scrape_session_id/questions/:id(.:format)                                        questions#update
                                              PUT    /scrape_sessions/:scrape_session_id/questions/:id(.:format)                                        questions#update
                                              DELETE /scrape_sessions/:scrape_session_id/questions/:id(.:format)                                        questions#destroy
                              scrape_sessions GET    /scrape_sessions(.:format)                                                                         scrape_sessions#index
                                              POST   /scrape_sessions(.:format)                                                                         scrape_sessions#create
                           new_scrape_session GET    /scrape_sessions/new(.:format)                                                                     scrape_sessions#new
                          edit_scrape_session GET    /scrape_sessions/:id/edit(.:format)                                                                scrape_sessions#edit
                               scrape_session GET    /scrape_sessions/:id(.:format)                                                                     scrape_sessions#show
                                              PATCH  /scrape_sessions/:id(.:format)                                                                     scrape_sessions#update
                                              PUT    /scrape_sessions/:id(.:format)                                                                     scrape_sessions#update
                                              DELETE /scrape_sessions/:id(.:format)                                                                     scrape_sessions#destroy
                                       signup GET    /signup(.:format)                                                                                  users#new
                                       signin GET    /signin(.:format)                                                                                  sessions#new
                                      signout DELETE /signout(.:format)                                                                                 sessions#destroy
                                         help GET    /help(.:format)                                                                                    static_pages#help
                                        about GET    /about(.:format)                                                                                   static_pages#about
                                         root GET    /                                                                                                  static_pages#home
