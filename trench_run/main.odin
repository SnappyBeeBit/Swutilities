package main 
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strconv"
import "core:strings"

Piett : []f32 : {0,0,13,9,0,6,9,4,5,2,2}
main :: proc () {
	show_debug := len(os.args) > 2 && os.args[2] == "y"
	deck_list : []f32
	bytes, err := os2.read_entire_file_from_path("input.csv", context.allocator)
	input := string(bytes)
	lines, _ := strings.split_lines(input)
	first_line := lines[0]
	comment_removed, _ := strings.split(first_line, " #")
	deck_as_costs : [dynamic]f32 = make([dynamic]f32)
	for i in strings.split_iterator(&comment_removed[0], ",") {
		value := strconv.parse_f32(string(i)) or_break
		append(&deck_as_costs, value)
	}
	
	calc_odds(deck_as_costs[:], os.args[1], show_debug)
}

calc_odds :: proc(input: []f32, question: string, show_debug: bool = true) {
	question_value, _ := strconv.parse_int(question)
	Damages : [14]f32;
	deck_size : f32 = 0.0
	for value in input {
		deck_size += value
	}
	for count, idx1 in input {
		if count == 0 do continue
		for second_card, idx2 in input {
			if second_card == 0 do continue
			damage := abs(idx1 - idx2)
			probability : f32 = count/50 * second_card/49
			Damages[int(damage)] += probability
		}
	}
	total_prob : f32 = 0
	answer : f32 = 0
	for probability, value in Damages {
		if probability == 0 do continue
		if show_debug {
			fmt.println("Damage Count: ", value, " Probability: ", probability * 100)
		}
		total_prob += probability
		if value >= question_value do answer += probability
	}
	if show_debug {
		fmt.println("Total Probability: ", total_prob*100)
		fmt.println("Decksize: ", deck_size)
	}
	fmt.println("Question: ", question_value, "Odds: ", answer * 100)
	
}