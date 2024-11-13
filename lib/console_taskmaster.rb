require "json"

def tasks()
    path_a = "json_tabeller/tasks.json"
    jsonString_a = File.read(path_a)
    tasks = JSON.parse(jsonString_a)

    path_b = "json_tabeller/bruker.json"
    jsonString_b = File.read(path_b)
    users = JSON.parse(jsonString_b)

    path_c = "json_tabeller/task_record.json"
    jsonString_c = File.read(path_c)
    task_records = JSON.parse(jsonString_c)


    puts "Which task was completed?"

    tasks.each do | task | 
        puts "#{task["id"]}: #{task["task"]} for #{task["points"]} points"
    end


    input = gets.chomp
    match_found = false

    tasks.each do | task |
        if input == task["id"]

            update_points = users.find { |user| user["id"] == $userID }
            update_points["points"] += task["points"]
            File.write(path_b, JSON.dump(users))

            task_records << {"userID" => $userID, "taskID" => task["id"]}
            File.write(path_c, JSON.dump(task_records))

            puts "" 
            puts "Logged task: #{task["id"]}. You got +#{task["points"]} points"
            puts "" 
            match_found = true
            hub()
        end
    end

    unless match_found
        puts "No such task. Please try again.."
        tasks()
    end
end

def user(name)
    path = "json_tabeller/bruker.json"
    jsonString = File.read(path)
    rubyarray = JSON.parse(jsonString)

    match_found = false
    rubyarray.each do | user | 
        if name == user["name"]
            puts "Welcome #{user["name"]}!"
            puts ""
            $userID = user["id"]
            $loop = false
            match_found = true
        end
    end

    unless match_found
        puts "Did not find name, please try again.."
        puts ""
    end
end

def profile()
    path_b = "json_tabeller/bruker.json"
    jsonString_b = File.read(path_b)
    users = JSON.parse(jsonString_b)

    points = users.find { |user| user["id"] == $userID }
    

    puts "-------Your Profile-------"
    puts "Firstname: #{$user_name}"
    puts "Points gathered: #{points["points"]}"

    puts "Go Back? (yes/no)"

    input = gets.chomp.upcase
    puts ""

    if input == "YES"
        hub()
    end

end

def exit_program()

end 

def hub()

    choices = [
        {"id" => "1", "name" => "Check Profile", "action" => method(:profile)},
        {"id" => "2", "name" => "Log a new task", "action" => method(:tasks)},
        {"id" => "3", "name" => "Exit Program", "action" => method(:exit_program)}
    ]

    puts "Where do you want to go?"

    choices.each do | choice |
        puts "#{choice["id"]}: #{choice["name"]}"
    end 

    puts "(Type the number)"
    input = gets.chomp
    puts ""

    match_found = false
    choices.each do | choice |
        if input == choice["id"]
            puts ""
            match_found = true
            choice["action"].call
        end
    end

    unless match_found
        puts "Not a valid choice. Please try again.."
        puts ""
        hub()
    end
end 



$loop = true

while $loop == true
    puts "Type your name"
    $user_name = gets.chomp.capitalize
    puts ""

    user($user_name)
end 

if $loop == false
    hub()
end


