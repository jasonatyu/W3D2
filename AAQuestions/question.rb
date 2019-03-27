require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'
require 'byebug'

class Question < ModelBase

  def self.find_by_id(id)
    super(id)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT 
        * 
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    raise 'no question in database' if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  attr_accessor :id, :title, :body, :author_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def save 
    if self.id 
      QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id, self.id)
        UPDATE
          questions
        SET
          title = ?, body = ?, author_id = ?
        WHERE
          id = ?
      SQL
    else 
      QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

  def author
    User.find_by_id(author_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers 
    QuestionFollow.followers_for_question_id(id)
  end

  def likers 
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

end