package main
import "core:fmt"
import "core:os"
import "core:os/os2"
import "core:strconv"
import "core:strings"

Piett: []f32 : {0, 0, 13, 9, 0, 6, 9, 4, 5, 2, 2}
main :: proc() {
	show_debug := len(os.args) > 2 && os.args[2] == "y"
	list, _ := strconv.parse_int(os.args[3])
	
	bytes, err := os2.read_entire_file_from_path("input.csv", context.allocator)
	input := string(bytes)
	lines, _ := strings.split_lines(input)
	first_line := lines[list]
	comment_splitted, _ := strings.split(first_line, " #")
	deck_as_costs: [dynamic]f32 = make([dynamic]f32)
	for i in strings.split_iterator(&comment_splitted[0], ",") {
		value := strconv.parse_f32(string(i)) or_break
		append(&deck_as_costs, value)
	}

	calc_odds(deck_as_costs[:], os.args[1], show_debug)
}

calc_odds :: proc(input: []f32, question: string, show_debug: bool = true) {
	question_value, _ := strconv.parse_int(question)
	Damages: [14]f32
	deck_size: f32 = 0.0
	for value in input {
		deck_size += value
	}

	TotalPairs: f32 = deck_size * (deck_size - 1)

	for c1, i in input {
		if c1 == 0 do continue

		// same cost (i → i)
		Damages[0] += (c1 * (c1 - 1)) / TotalPairs

		// different costs
		for j := int(i) + 1; j < len(input); j += 1 {
			c2 := input[j]
			if c2 == 0 do continue

			d := abs(int(i) - j)
			Damages[d] += (2 * c1 * c2) / TotalPairs
		}
	}


	total_prob: f32 = 0
	answer: f32 = 0
	for probability, damage in Damages {
		if probability == 0 do continue
		if show_debug {
			fmt.println("Damage Count: ", damage, " Probability: ", probability * 100)
		}
		total_prob += probability
		if damage >= question_value do answer += probability
	}
	if show_debug {
		fmt.println("Total Probability: ", total_prob * 100)
		fmt.println("Decksize: ", deck_size)
	}
	fmt.println("Question: ", question_value, "Odds: ", answer * 100)

}
