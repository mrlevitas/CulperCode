
#!/usr/bin/env ruby
require 'csv'
require "lemmatizer"

CulperCode = File.open('.\CulperCodesCSV.csv')

def decrypt_message(decrypt_me)
	
	culper_code_hash = {}

	# set up culper code hash from provided CSV key
	CSV.foreach(CulperCode) do |row|
	    number, word = row
	    culper_code_hash[number] = word
	  end

	# split the string by whitespace into an array
	decrypt_me_arr = decrypt_me.split(" ")

	# loop over every word in array
	decrypt_me_arr.each do |word|
		
		# word is a number
		if word.include?("_")
			word.tr!("efgikmnoqu","1234567890")
			word.gsub!('_','')
		
		# word is in key/dict
		elsif culper_code_hash[word]
			word.gsub!(/\S+/, culper_code_hash)
		
		# word is not in dictionary & not a number
		else 
			# non dictionary word mapping (supports capital letters as well)
			word.tr!("efghijabcdomnpqrkluvwxyzstEFGHIJABCDOMNPQRKLUVWXYZST","abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
		end
	end

	decrypted = decrypt_me_arr.join(" ")
	return decrypted
end


def encrypt_message(encrypt_me)
	
	culper_code_hash = {}
	# lemmatizer used to check for word variants
	lem = Lemmatizer.new

	# set up culper code hash from provided CSV key
	CSV.foreach(CulperCode) do |row|
	    number, word = row
	    culper_code_hash[word] = number
	end

	# split the string by whitespace into an array
	# include extra element in array ('.' in this case) for .each_cons iterator
	# to work on last word of input since it moves through list by every 
	# 2 consecutive elements
	encrypt_me_arr = encrypt_me.split(" ") << "."
	# array to be returned, encoded words are appended to it
	encrypted_arr = []

	# flag to be used in loop below for "combined words"
	skip_to_next = false

	# loop over array: every consecutive 2 elements
	encrypt_me_arr.each_cons(2) do |word1 , word2|
		# combined necessary for encrypting words w/ 2 strings in them 
		# i.e. "New York" or "Gen Washington"
		combined = word1 + " " + word2
		
		# if a combined word appears, iterate to next set of words in array
		if skip_to_next
			# reset flag
			skip_to_next = false
			next
		end

		# check if single word is in dictionary
		if culper_code_hash[word1]
			word = word1.gsub(/\S+/, culper_code_hash)
			encrypted_arr << word

		# check if lemma of word is in dictionary & prepend '~' to it
		# BEAST mode
		elsif culper_code_hash[lem_word = lem.lemma(word1)]
			word = lem_word.gsub(/\S+/, culper_code_hash)
			word.prepend("~")
			encrypted_arr << word
		
		# check if word contains numbers
		elsif word1 =~ /\d/
			# number map/cipher
			word = word1.tr("1234567890", "efgikmnoqu")
			# add underscores around encoded number
			word.prepend("_").concat("_") # word.gsub!(/\S+/ , '_\&_') 
			encrypted_arr << word	
				
		# check if each combination of 2 consecutive words is in dictionary
		elsif culper_code_hash[combined]
			# set flag to iterate to next set of words in array
			skip_to_next = true
			encrypted_arr << culper_code_hash[combined]					
		
		# word is not found in dictionary and is not a number
		else
			# non dictionary word mapping/cipher (supports capital letters as well)
			word = word1.tr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "efghijabcdomnpqrkluvwxyzstEFGHIJABCDOMNPQRKLUVWXYZST")
			encrypted_arr << word
		end
	end

	return encrypted_arr.join(" ")
end

# "main" part of script that calls encrypt/decrypt methods based on user input
loop do
	puts "Would you like to decrypt or encrypt a message? Type 'D' for decrypt or 'E' for encrypt...or 'q' to quit"
	input = gets.chomp

	# quit
	if (input == 'q' || input =='Q')
		exit

	#  decrypt
	elsif (input == 'D' || input == 'd')
		puts "Type in message to decrypt!"
		message = gets.chomp
		decrypted = decrypt_message(message)
		puts decrypted
	
	# encrypt
	elsif (input == 'E' || input == 'e')
		puts "Type in message to encrypt!"
		message = gets.chomp
		encrypted = encrypt_message(message)
		puts encrypted
	
	# retry
	else
		puts "incorrect input, please ntry again." 
	end
end