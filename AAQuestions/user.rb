require_relative 'questions_database'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'model_base'

require 'byebug'

class User < ModelBase

  def self.find_by_id(id)
    super(id)
  end

  def self.from
    self.to_s.tableize
  end

  def self.where(options)
    super(options)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT 
        * 
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    raise 'no user in database' if data.empty?
    user = User.new(data[0])
  end

  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies 
    Reply.find_by_user_id(id)
  end

  def followed_questions 
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions 
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT 
        AVG(CAST(n_likes AS FLOAT))
      FROM
        (SELECT
          q.id, COUNT(DISTINCT ql.id) AS n_likes
        FROM
          questions q
        JOIN
          question_likes ql
        ON 
          q.id = ql.question_id
        WHERE
          q.author_id = ?
        GROUP BY
          q.id
        ) AS s
    SQL
    data[0]
  end

  def save 
    if self.id 
      QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    else 
      QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end

end