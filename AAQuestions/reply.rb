require_relative 'questions_database'
require_relative 'user'
require_relative 'question'
require_relative 'model_base'
require 'byebug'

class Reply < ModelBase

  def self.find_by_id(id)
    super(id)
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        * 
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    raise 'no reply in database' if data.empty?
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
        * 
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    raise 'no reply in database' if data.empty?
    # question = Question.new(data[0])
    data.map { |datum| Reply.new(datum) }
  end

  attr_accessor :id, :question_id, :user_id, :body, :reply_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @body = options['body']
    @reply_id = options['reply_id']
  end

  def save 
    if self.id 
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.user_id, self.body, self.reply_id, self.id)
        UPDATE
          replies
        SET
          question_id = ?, user_id = ?, body = ?, reply_id = ?
        WHERE
          id = ?
      SQL
    else 
      QuestionsDatabase.instance.execute(<<-SQL, self.question_id, self.user_id, self.body, self.reply_id)
        INSERT INTO
          replies (question_id, user_id, body, reply_id)
        VALUES
          (?, ?, ?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def author 
    User.find_by_id(user_id)
  end

  def question 
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(reply_id)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, reply_id)
      SELECT 
        * 
      FROM
        replies
      WHERE
        reply_id = ?
    SQL
    raise 'no child replies in database' if data.empty?
    replies = data.map { |datum| Reply.new(datum) }
  end

end