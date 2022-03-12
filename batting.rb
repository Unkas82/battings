require 'bundler'
Bundler.require

class Batting

  def run
    print "Select yearId: "
    selected_year = gets.chomp

    print "Select teamId: "
    selected_team_id = gets.chomp

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

      break if i > 2
      i += 1
    end
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
    # binding.pry
    hits = rows.inject(0){|sum,x| sum + x['H'].to_i }
    at_bats = rows.inject(0){|sum,x| sum + x['AB'].to_i }

    (hits.to_f / at_bats.to_f).round(3).to_s
  end
end

Batting.new.run
