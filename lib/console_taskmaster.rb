require "json"
require "colorize"
require "tty-prompt"

def load_json(path)
    JSON.parse(File.read(path))
rescue Errno::ENOENT
    puts "File not found: #{path}"
    exit
rescue JSON::ParserError
    puts "Invalid JSON in file: #{path}"
    exit
end

def write_json(path, data)
    File.write(path, JSON.dump(data))
rescue IOError
    puts "Error writing to file: #{path}"
    exit
end



$tasks = load_json("json_tabeller/tasks.json")
$users = load_json("json_tabeller/bruker.json")
$task_records = load_json("json_tabeller/task_record.json")

def clear_screen
    system('clear')
end









def tasks()
    clear_screen
    prompt = TTY::Prompt.new
    task_choices = $tasks.map { |task| "#{task['task']} - #{task['points']} points"}

    selected_task_choice = prompt.select("Which task was completed?".bold.yellow, task_choices, active_color: :yellow)

    selected_task = $tasks.find { |task| "#{task['task']} - #{task['points']} points" == selected_task_choice}

    if selected_task
        user = $users.find { |u| u["id"] == $current_user["id"]}
        user["points"] += selected_task["points"]

        $task_records << {"userID" => $current_user["id"], "taskID" => selected_task["id"]}

        write_json("json_tabeller/bruker.json", $users)
        write_json("json_tabeller/task_record.json", $task_records)

        puts "\nLogged task: #{selected_task['task']}. You got +#{selected_task['points']} points\n"

        
        print "\nRedirecting".green
        sleep(0.7)
        print ".".green
        sleep(0.7)
        print ".".green
        sleep(1)
        hub()

    else
        print "\nERROR: No such task. Please try again..".bold.red
        sleep(0.7)
        print ".".bold.red
        sleep(0.7)
        print ".".bold.red
        sleep(1)

        tasks()
    end
end

def profile()
    clear_screen
    points = $users.find { |u| u["id"] == $current_user["id"] }
    

    puts "-------#{$current_user["name"]}-------".bold.blue
    puts "Firstname: #{$current_user["name"]}".green
    puts "Points gathered: #{points["points"]}".green

    prompt = TTY::Prompt.new
    choice = prompt.yes?("Go back?".blue)
        
    if choice
        print "\nRedirecting".green
        sleep(0.7)
        print ".".green
        sleep(0.7)
        print ".".green
        sleep(0.7)

        hub()
    else
        print "\nGoodbye".green
        sleep(0.5)
        print "."
        sleep(0.5)
        print "."
        sleep(0.5)
        print ".#{$current_user["name"]}\n".bold.red
        sleep(1)
        exit
    end
end

def exit_program()
    exit
end 

def hub()
    clear_screen
    prompt = TTY::Prompt.new

    choice = prompt.select("Where do you want to go?".bold.green) do |menu|
        menu.choice "Check Profile", -> { profile }
        menu.choice "Log a new task", -> { tasks }
        menu.choice "Exit Program", -> { exit_program }
    end
    choice.call
end 


def start()
    clear_screen
    prompt = TTY::Prompt.new
    user_names = $users.map { |u| u["name"]}

    selected_user_name = prompt.select("Who are you?".bold.green, user_names)

    selected_user = $users.find { |user| user["name"] == selected_user_name}
    $current_user = { "id" => selected_user["id"], "name" => selected_user["name"] }

    if selected_user
        clear_screen
        puts "Welcome to TaskMaster #{$current_user["name"]}!\n".bold.green
        sleep(2)
        hub()
    else
        puts "Did not find user. Please try again..".bold.red
        sleep(2)
        start()
    end
end



$current_user = nil
start()







