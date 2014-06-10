# This code models a library. Libraries, shelves, and books are all distinct objects, nested
# in the expected order (libraries contain an array of shelves, shelves contain an array of books). 
# Books can be made and added to/removed from shelves. The Library can always report what books
# it has. 

# I made this code to be versatile - while it is only meant to handle one library at the moment,
# it can handle an entire network of libraries containing any number of shelves and books. The 
# framework is made to easily permit additional functions and more detailed data collection. 

class Library 
	attr_accessor :libraryName, :num_shelves, :shelves
	
	# Sets up a new Library with a name and a certain number of shelves. Shelves are 
	# stored in an array. 
	def initialize(name, num_shelves)
		@libraryName = name
		@num_shelves = num_shelves
		@shelves = []
		num_shelves.times { |shelf| self.shelves << Shelf.new(shelf) }
	end
	
	# Searches the shelves in the library and prints the list of books available. 
	# All information is available from a Library since Libraries contain the shelves and
	# books nested within them. 
	def readLibrary
		puts "#{@libraryName} contains the following books:"
		@shelves.each do |shelf| 
			shelf.books.each { |book| puts book.bookName }
		end
	end
end 

class Shelf
	attr_accessor :books
	attr_reader :shelfID
	
	# Books are stored in an array within each shelf object. 
	def initialize(i)
		@books = []
		@shelfID = "Shelf " + (i + 1).to_s
	end
end

class Book
	attr_accessor :library, :shelf, :bookName
	
	# Books are not shelved when made. 
	def initialize(name)
		@library = nil
		@shelf = nil
		@bookName = name
		puts "#{self.bookName} created"
	end
	
	# Updates the Book to have information on its own location. The Shelf object is updated
	# to include the newly shelved Book. 
	def enshelve(library, shelf)
		# Avoids multiple filing of the same book. A book must be unshelved before it can 
		# be shelved somewhere else. 
		unless @library == nil && @shelf == nil
			puts "#{@bookName} can not be reshelved until it is unshelved."
			return
		end
		@library = library.libraryName
		@shelf = shelf.shelfID
		shelf.books << self
		puts "#{self.bookName} added to #{shelf.shelfID} of #{library.libraryName}"
	end
	
	# Unshelves the book, returning it to its original state. This is the exact opposite of 
	# the Enshelve function. 
	def unshelve(library, shelf)
		if shelf.books.include? self
			shelf.books.delete_at(shelf.books.find_index { |book| book == self })
			@library = nil
			@shelf = nil
			puts "#{self.bookName} unshelved"
		else 
			puts "Error: #{self.bookName} not found on #{shelf.shelfID} of #{library.libraryName}"
		end
	end
end 

# Example of the code. This creates multiple books and exhibits the functions of the library system. 
libraries = { "IL12" => Library.new("Twelfth International Library", 2) }
a = Book.new("Anatomy and Physiology of Speech Production")
x = Book.new("Cinderella")
y = Book.new("A Tale of Two Cities")
z = Book.new("John Carter of Mars")
a.enshelve(libraries["IL12"], libraries["IL12"].shelves[0])
x.enshelve(libraries["IL12"], libraries["IL12"].shelves[0])
y.enshelve(libraries["IL12"], libraries["IL12"].shelves[0])
z.enshelve(libraries["IL12"], libraries["IL12"].shelves[0])
libraries["IL12"].readLibrary
a.enshelve(libraries["IL12"], libraries["IL12"].shelves[1])
libraries["IL12"].readLibrary
y.unshelve(libraries["IL12"], libraries["IL12"].shelves[0])
x.unshelve(libraries["IL12"], libraries["IL12"].shelves[1]) # Error because book not found
libraries["IL12"].readLibrary
