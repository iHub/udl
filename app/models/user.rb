class User < ActiveRecord::Base
	
	# associations
	has_many :scrape_sessions, 		dependent: :destroy
	has_many :scrape_sessions_logs, dependent: :destroy
	
############Tagger && TwitterParser#####################################
	has_many :disqus_forums
	has_many :tweet_taggers
  has_many :tweets, :through => :tweet_taggers, class_name: "TwitterParser::Tweet"
  
  has_many :tagger_posts, :class_name => "Tagger::TaggerPost"
	has_many :tagged_posts, :through => :tagger_posts, :source => :tweet
#################################################################################

	# validations---------------
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
	validates :firstname,  presence: true, length: { maximum: 50 }
	validates :lastname,   presence: true, length: { maximum: 50 }

	validates :email, 
				presence: true, 
				format: { with: VALID_EMAIL_REGEX },
				uniqueness: true

	validates :password, length: { minimum: 6 }

	#---------------------------

	before_save { self.email = email.downcase }
	before_create :create_remember_token

	has_secure_password

	#authentication stuff & session management
	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def to_s
		username
	end
	
	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def username
		"#{self.firstname.capitalize} #{self.lastname.capitalize}"
	end
	#app specific
	def isadmin?
  		self.role == "admin"
  end

	def ismanager?
		ismanageronly? || self.role == "admin"
	end

	def ismanageronly?
		self.role == "manager"
	end

	def isannotator?
		self.role == "annotator"
	end
	
	def is_owner?
		self.ismanager? && self.current_user?(current_user)
	end

	private

		def create_remember_token
		  self.remember_token = User.encrypt(User.new_remember_token)
		end
end