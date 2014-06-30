# This code models a library. Libraries, shelves, and books are all distinct objects, nested
# in the expected order (libraries contain a hash of shelves, shelves contain an array of books). 
# Books can be made and added to/removed from shelves. The Library can always report what books
# it has. 

# I made this code to be versatile - it can easily handle an entire network of libraries 
# containing any number of shelves and books. Additional functions could easily be added
# in, such as an interlibrary loan. 

class Library 
	attr_accessor :name, :num_shelves, :shelves, :storage
	
	# Sets up a new Library with a name and a certain number of shelves. Shelves are 
	# stored in a hash with the keys being their ID's. The shelves also have a max
	# capacity, above which they will not store additional books. 

	# Also, note that it has an optional parameter for the organization of the shelves. 
	# By default, the shelves are labeled :shelf_1, :shelf_2, :shelf_3, etc. 
	# Alternatively, you can pass it a more descriptive array of your own choosing such as - 
	# %w[fiction_1 history_2nd_floor only_dragonball_z]. An example of this is shown. 

	def initialize(name, num_shelves, shelf_capacity, org = [] )
		num_shelves.times { |id| org << "shelf_#{id + 1}" } unless org.any?
		@name = name
		@shelves = Hash.new
		@storage = [] # Infinite capacity "shelf" for unshelved books. 
		return puts "Error: id array does not match number of shelves \n\n" if org.size != num_shelves
		org.each { |id| self.shelves.store(id.to_sym, Shelf.new(id, shelf_capacity)) }
	end
	
	# Searches the shelves in the library and prints the list of books available. 
	# All information is available from a Library since Libraries contain the shelves and
	# books nested within them. 

	def readLibrary
		puts "#{@name} contains the following books: \n\n"
		@shelves.each do |id, shelf| 
			puts "#{id}:"
			shelf.books.any? ? (shelf.books.each { |book| puts "\t #{book.name}" }) : (puts "\t Empty")
		end
		puts "storage:"
		@storage.any? ? (@storage.each { |book| puts "\t #{book.name}" }) : (puts "\t Empty")
		puts "\n"
	end
end 

class Shelf
	attr_accessor :books, :shelfID, :capacity
	
	# Books are stored in an array within each shelf object. 
	def initialize(id, capacity)
		@books = []
		@shelfID = id
		@capacity = capacity
	end
end

class Book
	attr_accessor :library, :shelf, :name
	
	# Books are put in storage when they are made, not immediately shelved. 
	def initialize(library, name)
		@library = nil
		@shelf = nil
		@name = name
		library.storage << self
		puts "#{self.name} created \n\n"
	end
	
	# Updates the Book to have information on its own location. The Shelf object is updated
	# to include the newly shelved Book. Shelves at max capacity will result in the book staying
	# in storage. Also, if a book is already shelved, it is automatically unshelved before reshelving. 
	def enshelve(library, shelfID)
		shelf = library.shelves[shelfID.to_sym]
		return puts "Shelving failed - #{shelfID} is at max capacity \n\n" unless shelf.capacity > shelf.books.size 
		unshelve(library) if @library || @shelf 
		library.storage.delete_at(library.storage.find_index { |book| book == self })
		@library = library.name
		@shelf = shelfID
		shelf.books << self
		puts "#{self.name} added to #{@shelf} of #{library.name} \n\n"
	end
	
	# Unshelves the book, returning it to storage. 
	def unshelve(library)
		shelf_books = library.shelves[@shelf.to_sym].books # Refactored for brevity
		if shelf_books.include? self
			shelf_books.delete_at(shelf_books.find_index { |book| book == self })
			@library = nil
			@shelf = nil
			library.storage << self
			puts "#{self.name} unshelved and returned to storage \n\n"
		else 
			puts "Error: #{self.name} not found at #{@shelf} of #{library.name} \n\n"
		end
	end
end 


# Example. This creates a library with three shelves holding 100 books each maximum. 
myLibrary = Library.new("Twelfth International Library", 3, 100, %w[fiction_1 classics_1 science_1])

# Note: Comment the above line and uncomment the next one to see what happens when each shelf
# can only hold a single book!

# myLibrary = Library.new("Twelfth International Library", 3, 1, %w[fiction_1 classics_1 science_1])
(a = Book.new(myLibrary, "Anatomy and Physiology of Speech Production")).enshelve(myLibrary, "science_1")
(y = Book.new(myLibrary, "Cinderella")).enshelve(myLibrary, "fiction_1")
(x = Book.new(myLibrary, "A Tale of Two Cities")).enshelve(myLibrary, "classics_1")
(z = Book.new(myLibrary, "John Carter of Mars")).enshelve(myLibrary, "fiction_1")

myLibrary.readLibrary
y.enshelve(myLibrary, "classics_1") # Automatically unshelves and reshelves
myLibrary.readLibrary
y.unshelve(myLibrary)
myLibrary.readLibrary
