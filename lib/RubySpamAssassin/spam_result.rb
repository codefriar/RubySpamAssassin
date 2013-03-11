class RubySpamAssassin::SpamResult
  attr_accessor :response_version,
                :response_code,
                :response_message,
                :spam,
                :score,
                :threshold,
                :tags,
                :report,
                :content_length,
                :rules

  #returns true if the message was spam, otherwise false
  def spam?
    (@spam == "True" || @spam == "Yes") ? true : false
  end
end