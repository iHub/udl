class TestPostsController < ApplicationController

  

  def index

  end

  def get_fb_posts(fb_page_id, start_date, end_date)

    logger.debug "============ Running get_fb_posts ==============="

    query_limit  = 500
    posts_fql_query = "SELECT post_id, message, created_time FROM stream WHERE source_id = '#{fb_page_id}' AND message != '' AND created_time > #{start_date} AND created_time < #{end_date} LIMIT #{query_limit}"

    fb_posts = fb_graph.fql_query(posts_fql_query)

    if !fb_posts.empty?
        
        logger.debug "----- Before Save ----------"
        logger.debug "fb_posts.inspect => #{fb_posts.inspect}"

        save_fb_posts fb_page_id, fb_posts

        logger.debug "@last_result_created_time => #{@last_result_created_time}"
        logger.debug "start_date => #{start_date}"
        logger.debug "end_date => #{end_date}"

        if @last_result_created_time > start_date
            logger.debug "@last_result_created_time < start_date => true"
            logger.debug "@last_result_created_time => #{@last_result_created_time} vs start_date => #{start_date}"
            get_fb_posts fb_page_id, start_date, @last_result_created_time
        end

    elsif fb_posts.empty?
        logger.debug "###################### fb_posts is Empty!"
    end

  end

  def save_fb_posts(fb_page_id, fb_posts)
    logger.debug "_________________ save_fb_posts ____________________"
    logger.debug "fb_posts.nil? => #{fb_posts.nil?}"

    
    fb_posts.each do |fb_post|
        this_post = {}
        this_post[:fb_post_id] = fb_post["post_id"]
        this_post[:created_time] = Time.at(fb_post["created_time"]).utc
        this_post[:message] = fb_post["message"]
        this_post[:fb_page_id] = fb_page_id
        
        current_post = FbPost.new(this_post)

        this_post_created_at = (current_post.created_time).to_time.utc.to_i

        @last_result_created_time = this_post_created_at

        logger.debug "@last_result_created_time => #{@last_result_created_time}"

        # if @last_result_created_time <  this_post_created_at
        #     @last_result_created_time = this_post_created_at
        # end

        if current_post.save
            logger.debug "!!!!!!!!!!!!!!!!!! Record Saved !!!!!!!!!!!!!!!!!!"
        end
    end

    logger.debug "**************** save_fb_posts complete ****************"
    # logger.debug ""

  end

  def test
    
    fb_post = FbPost.last

    @test_feed = fb_graph.get_object(fb_post.fb_post_id, :fields => "comments.fields(comments.fields(from,message,created_time),message,from,created_time)")

    current_page = @test_feed.next_page

    @comment_list = []
    @comment_count = 0

    current_page["comments"]["data"].each do |comment|

        this_comment = {}
        this_comment[:comment_id]      = comment["id"]
        this_comment[:message]         = comment["message"]
        this_comment[:from_user_id]    = comment["from"]["id"]
        this_comment[:from_user_name]  = comment["from"]["name"]
        this_comment[:created_time]    = comment["created_time"]
        this_comment[:fb_post_id]      = fb_post.id
        this_comment[:parent_id]       =  "0"

        @get_next_page = true

        fb_comment = fb_post.fb_comments.build(this_comment)

        @comment_list << this_comment

        # if fb_comment.save
        #   @comment_count +=1
        #   logger.debug "SAVED. @comment_count = #{@comment_count}"
        # end

        # grab nested comments
        if !comment["comments"].nil?
            comment["comments"]["data"].each do |comment_reply|
                nested_comment = {}
                nested_comment[:comment_id]      = comment_reply["id"]
                nested_comment[:message]         = comment_reply["message"]
                nested_comment[:from_user_id]    = comment_reply["from"]["id"]
                nested_comment[:from_user_name]  = comment_reply["from"]["name"]
                nested_comment[:created_time]    = comment_reply["created_time"]
                nested_comment[:fb_post_id]      = fb_post.id
                nested_comment[:parent_id]       = this_comment[:comment_id]

                @comment_list << nested_comment

                fb_comment = fb_post.fb_comments.build(nested_comment)

                # if fb_comment.save
                #   @comment_count +=1
                #   logger.debug "SAVED -- Nested comment. @comment_count = #{@comment_count}"
                # end
            end
        end

    end

  end


  def comments_fql


    @comment_list = []
    @init_comment_count = 0
    @saved_comments = 0
    start_date   = 1.day.ago.to_time.utc.to_i         # convert date to unix epoch time
    end_date     = Time.now.to_time.utc.to_i

    fb_post_id   = '40941045532_10153772835765533'
    # start_date   =
    # end_date     =
    query_limit  = 500
    
    @comments = fb_graph.get_object(fb_post_id, :fields => "comments.fields(comments.fields(from,message,created_time),message,from,created_time).limit(1000)")

    if !@comments["comments"].nil?
        
        @comments["comments"]["data"].each do |comment|

            this_comment = {}
            this_comment[:comment_id]      = comment["id"]
            this_comment[:message]         = comment["message"]
            this_comment[:from_user_id]    = comment["from"]["id"]
            this_comment[:from_user_name]  = comment["from"]["name"]
            this_comment[:created_time]    = comment["created_time"]
            this_comment[:fb_post_id]      = fb_post_id
            this_comment[:parent_id]       =  "0"

            # @get_next_page = true

            # fb_comment = fb_post.fb_comments.build(this_comment)

            @comment_list << this_comment


            @init_comment_count +=1  

            # if fb_comment.save
            #   @saved_comments +=1
            #   logger.debug "SAVED. @init_comment_count = #{@init_comment_count}"
            # end

            # grab nested comments
            if !comment["comments"].nil? 
              comment["comments"]["data"].each do |comment_reply|
                  nested_comment = {}
                  nested_comment[:comment_id]      = comment_reply["id"]
                  nested_comment[:message]         = comment_reply["message"]
                  nested_comment[:from_user_id]    = comment_reply["from"]["id"]
                  nested_comment[:from_user_name]  = comment_reply["from"]["name"]
                  nested_comment[:created_time]    = comment_reply["created_time"]
                  nested_comment[:fb_post_id]      = fb_post_id
                  nested_comment[:parent_id]       = this_comment[:comment_id]

                  @comment_list << nested_comment

                  fb_comment = fb_post.fb_comments.build(nested_comment)
                  
                  @init_comment_count +=1

                  if fb_comment.save
                    @saved_comments +=1
                    logger.debug "SAVED -- Nested comment. @comment_count = #{@comment_count}"
                  end
              end
            end

        end
        logger.debug "array populated"
    end

  end

  def comments
    scrape_page_id = 92

    @comment_list = []

    logger.debug "Pre:: all fb_posts query"
    fb_posts = FbPost.where(scrape_page_id: scrape_page_id)
    
    logger.debug "------------------ Query complete ------------------"

    @init_comment_count = 0

    fb_posts.each do |fb_post|

        post_feed = fb_graph.get_object(fb_post.fb_post_id)
        
        # logger.debug " graph complete "
       
        if !post_feed["comments"].nil?
        
            # @post_comments = []
            # @last_post_feed["comments"]["data"].each do |comment|
            #     @post_comments << comment
            # end

            
            post_feed["comments"]["data"].each do |comment|

                this_comment = {}
                this_comment[:comment_id]      = comment["id"]
                this_comment[:message]         = comment["message"]
                this_comment[:from_user_id]    = comment["from"]["id"]
                this_comment[:from_user_name]  = comment["from"]["name"]
                this_comment[:created_time]    = comment["created_time"]
                this_comment[:fb_post_id]      = fb_post.id
                this_comment[:parent_id]       =  "0"

                # @get_next_page = true

                fb_comment = fb_post.fb_comments.build(this_comment)

                @comment_list << this_comment


                # @init_comment_count +=1  

                # if fb_comment.save
                #   @init_comment_count +=1
                #   logger.debug "SAVED. @init_comment_count = #{@init_comment_count}"
                # end

                # grab nested comments
                if !comment["comments"].nil? 
                    nested_comment = {}
                    nested_comment[:comment_id]      = comment["id"]
                    nested_comment[:message]         = comment["message"]
                    nested_comment[:from_user_id]    = comment["from"]["id"]
                    nested_comment[:from_user_name]  = comment["from"]["name"]
                    nested_comment[:created_time]    = comment["created_time"]
                    nested_comment[:fb_post_id]      = fb_post.id 
                    nested_comment[:parent_id]       = this_comment[:comment_id]
                end

            end
            logger.debug "array populated"
        end
    end
    
  end

  private

    def fb_graph
        fb_graph ||= Koala::Facebook::API.new(fb_app_access_token)
    end

    def fb_app_access_token
      fb_app_access_token ||= AppSetting.last.fb_app_access_token
    end

end
