require_relative 'questions_database'
require 'byebug'

class QuestionLike

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        * 
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    question_like = QuestionLike.new(data[0])
  end

  def self.likers_for_question_id(questionid)
    data = QuestionsDatabase.instance.execute(<<-SQL, questionid)
      SELECT
        u.*
      FROM
        questions q
      JOIN
        question_likes ql
      ON 
        q.id = ql.question_id
      JOIN
        users u
      ON
        ql.user_id = u.id
      WHERE
        q.id = ?
    SQL
    likers = data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(questionid)
    data = QuestionsDatabase.instance.execute(<<-SQL, questionid)
      SELECT
        COUNT(DISTINCT ql.id)
      FROM
        questions q
      JOIN
        question_likes ql
      ON 
        q.id = ql.question_id
      WHERE
        q.id = ?
    SQL
    data[0]
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT 
        q.*
      FROM 
        questions q
      JOIN 
        question_likes ql 
      ON 
        q.id = ql.question_id 
      JOIN 
        users u 
      ON 
        ql.user_id = u.id 
      WHERE 
        u.id = ? 
    SQL
    questions = data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        q.*
      FROM
        questions q
      JOIN
        (SELECT 
          q.id, COUNT(DISTINCT ql.id) AS n_likes
        FROM 
          questions q 
        JOIN
          question_likes ql
        ON 
          q.id = ql.question_id
        GROUP BY
          q.id) a
      ON 
        q.id = a.id
      ORDER BY
        n_likes DESC
      LIMIT
        ?
    SQL
  end

  attr_accessor :id, :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

end