#![allow(unused)]

use std::collections::HashSet;

pub fn anagrams_for<'a>(word: &'a str, possible_anagrams: &'a [&str]) -> HashSet<&'a str> {
    let mut sorted_word: Vec<char> = word.to_lowercase().chars().collect();
    sorted_word.sort_unstable();

    let mut anagrams: HashSet<&str> = HashSet::new();
    for &anagram in possible_anagrams.iter().filter(|x| x.len() == word.len()) {
        if anagram.to_lowercase() == word.to_lowercase() {
            continue
        }

        let mut sorted_anagram: Vec<char> = anagram.to_lowercase().chars().collect();
        sorted_anagram.sort_unstable();

        if sorted_anagram == sorted_word {
            let _ = anagrams.insert(&anagram);
        }
    }

   anagrams
}
