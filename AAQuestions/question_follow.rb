require_relative 'questions_database'
require_relative 'user'
require 'byebug'

class QuestionFollow

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        * 
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    question_follow = QuestionFollow.new(data[0])
  end

  def self.followers_for_question_id(question_id)
     data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT 
        u.*
      FROM 
        question_follows qf
      JOIN 
        users u 
      ON 
        qf.user_id = u.id 
      JOIN 
        questions q 
      ON 
        qf.question_id = q.id 
      WHERE
        q.id = ?
     SQL
     users = data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(userid)
     data = QuestionsDatabase.instance.execute(<<-SQL, userid)
        SELECT 
          q.*
        FROM 
          question_follows qf
        JOIN 
          questions q 
        ON 
          qf.question_id = q.id 
        WHERE 
          qf.user_id = ?
      SQL
      data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions q
      JOIN
      (SELECT 
        q.id, COUNT(DISTINCT qf.user_id) AS n_followers
      FROM 
        questions q
      JOIN 
        question_follows qf 
      ON 
        q.id = qf.question_id
      GROUP BY
        q.id
      ) s
      ON q.id = s.id
      ORDER BY s.n_followers DESC
      LIMIT ?
    SQL
    questions = data.map { |datum| Question.new(datum) }
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end