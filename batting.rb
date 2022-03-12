require 'bundler'
Bundler.require

class Batting

  def run
    print "Input filter by yearId: "
    selected_year = gets&.chomp

    print "Input filter by teamId: "
    selected_team_id = gets&.chomp

    print "Input players count limit: "
    max_i = gets&.chomp&.to_i


    puts '+----------+--------+--------------------------------------------------+-----------------+'
    puts '| playerID | yearId | Team name(s)                                     | Batting Average |'
    puts '+----------+--------+--------------------------------------------------+-----------------+'

    i = 0
    all_the_players(selected_year, selected_team_id).each do |playerID|

      player_by_year = batting_table.
                        select{|row| row['playerID'] == playerID }.
                        group_by { |r| r['yearID'] }

      player_by_year.each do |player_year|
        yearID = player_year.first

        team_ids = player_year.last.map{|row| row['teamID']}
        teamNames= team_names(team_ids, yearID)
        battingAverage = batting_average(player_year.last)

        puts "|#{playerID.rjust(10)}|#{yearID.rjust(8)}|#{teamNames.rjust(50)}|#{battingAverage.rjust(17)}|"
      end

      break if max_i.positive? && i > max_i
      i += 1
    end
  end

############################################################
  def test
    headers_b = ['playerID', 'yearID', 'teamID', 'AB', 'H']
    data_b = [
      ['p1', '1982', 't1', 5, 1]
    ]

    csv_rows_b = []
    data_b.each do |row|
      csv_row = CSV::Row.new(headers_b, row)
      csv_rows_b << csv_row
    end
    @batting_table = CSV::Table.new(csv_rows_b)

    headers_t = ['yearID', 'teamID', 'name']
    data_t = [
      ['1982', 't1', 'Team 1']
    ]

    csv_rows_t = []
    data_t.each do |row|
      csv_row = CSV::Row.new(headers_t, row)
      csv_rows_t << csv_row
    end
    @teams_table = CSV::Table.new(csv_rows_t)

    run
  end

  private

  def teams_table
    @teams_table ||= CSV.parse(File.read('Team.csv'), headers: :first_row)
  end

  def batting_table(selected_year = '', selected_team_id = '')
    @batting_table ||= CSV.parse(File.read('Batting.csv'), headers: :first_row).
                        filter{|row| selected_team_id.empty? ? true : row['teamID'] == selected_team_id }.
                        filter{|row| selected_year.empty? ? true : row['yearID'] == selected_year }
  end

  def all_the_players(selected_year, selected_team_id)
    @all_the_players ||= batting_table(selected_year, selected_team_id).map{|row| row[0] }.uniq
  end

  def team_names(team_ids, year_id)
    team_rows = teams_table.filter_map{|row| row['name'] if (team_ids.include?(row['teamID']) && row['yearID'] == year_id)}
    team_rows.uniq.join(', ')
  end

  def batting_average(rows)
    hits = rows.inject(0){|sum,x| sum + x['H'].to_i }
    at_bats = rows.inject(0){|sum,x| sum + x['AB'].to_i }
    return 'NaN' if at_bats.zero?

    "%.3f" % (hits.to_f / at_bats.to_f)
  end
end

Batting.new.run
# Batting.new.test
