require 'active_support/inflector'
require 'byebug'

class ModelBase

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT 
        * 
      FROM
        #{self.to_s.tableize}
      WHERE
        id = ?
    SQL
    raise 'no item in database' if data.empty?
    self.new(data[0])
  end

  def self.where(parameters)
    params = []
    parameters.each do |k, v|
      params << "#{k} = '#{v}'"
    end
    params_string = params.join(' AND ') 
    debugger
    data = QuestionsDatabase.instance.execute(<<-SQL, params_string)
      SELECT 
        * 
      FROM
        #{self.to_s.tableize}
      WHERE
        #{params_string}
    SQL
    raise 'no item in database' if data.empty?
    data.map { |datum| self.new(datum) }
  end

  def initialize
  end

end