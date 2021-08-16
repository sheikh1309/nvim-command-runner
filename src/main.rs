use std::fs;
use serde_json::{Value as JsonValue, Map};
use neovim_lib::{Neovim, NeovimApi, Session};
use neovim_lib::Value;

struct Detector {
    commands: Vec<(Value, Value)>
}

impl Detector {
    fn new(file_name: String, commands_key: String) -> Detector {
        let mut commands_vec = Vec::new();
        let mut commands_map: Vec<(Value, Value)> = Vec::new();
        let data = fs::read_to_string(file_name).expect("Unable to read file");
        let json: JsonValue = serde_json::from_str(&data).expect("JSON does not have correct format.");
        let commands: &JsonValue = json.get(commands_key).expect("No Value");
        if commands.is_object() == true {
            let res: &Map<String, JsonValue> = commands.as_object().expect("No Object");
            
            let keys = res.keys();
            for key in keys {
                let value = res.get(key);
                match value {
                    Some(v) => {
                        match v.as_str() {
                            Some(data) => {
                                commands_map.push((Value::from(String::from(key)), Value::from(data)))
                            },
                            None => {}
                        }
                    },
                    None => {}
                }
                commands_vec.push(String::from(key));
            }
        }
        Detector { commands: commands_map }
    }
}


struct EventHandler {
    nvim: Neovim
}

impl EventHandler {

  fn new() -> EventHandler {
    let session = Session::new_parent().unwrap();
    let nvim = Neovim::new(session);
    EventHandler { nvim }
  }
  
  fn recv(&mut self) {
    let receiver = self.nvim.session.start_event_loop_channel();

    for (event, values) in receiver {
        match Messages::from(event) {
            Messages::Detect => {
                let mut params = values.iter();
                let file_name = params.next().unwrap().as_str().unwrap();
                let commands_key = params.next().unwrap().as_str().unwrap();
                let detector = Detector::new(String::from(file_name), String::from(commands_key));
                let scripts_map: Value = Value::from(detector.commands);
                let function_args = vec![scripts_map];
                let res = self.nvim.call_function("ToggleScriptsPannel", function_args);
                match res {
                    Ok(v) => println!("Ok = {}", v),
                    Err(e) => self.nvim.command(format!("echo 'Err = {}'", e).as_str()).unwrap()
                }
                
            }
            Messages::Unknown(event) => {
                self.nvim
                    .command(&format!("echo \"Unknown command: {}\"", event))
                    .unwrap();
            }
        }
    }
  }
}


enum Messages {
    Detect,
    Unknown(String),
}

impl From<String> for Messages {
    fn from(event: String) -> Self {
        match &event[..] {
            "detect" => Messages::Detect,
            _ => Messages::Unknown(event),
        }
    }
}


fn main() {
    let mut event_handler = EventHandler::new();
    event_handler.recv();
}
