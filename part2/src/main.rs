use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        println!("Usage: {} <name>", args[0]);
        return;
    }

    println!("{}", say_hello(&args[1]));
}

fn say_hello(name: &str) -> String {
    return format!("Hello, {}!", name);
}

#[test]
fn test_say_hello() {
    assert_eq!(say_hello("world"), "Hello, world!");
}
