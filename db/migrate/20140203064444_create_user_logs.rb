class CreateUserLogs < ActiveRecord::Migration
  def change
    create_table    :user_logs do |t|
        t.integer   :user_id
        t.string    :firstname
        t.string    :lastname
        t.string    :email
        t.string    :role
        t.datetime  :event_time
        t.string    :event_type 
        t.integer   :signin_count
        t.datetime  :current_sign_in_at
        t.datetime  :last_sign_in_at

        t.timestamps
    end

    add_index  :user_logs, :user_id

  end
end
