require 'sastrawi'

class HomeController < ApplicationController
  def index
    @book = Book.all
    @books = Book.all
    @hasil_search = params[:search]
    if params[:search]
      @books = Book.where('title like ?', "%#{params[:search]}%")
      @query_input = text_preprocessing(params[:search])
      document(@query_input)
      get_term(@query_input)
      idf()
      table_tf()
      pembobotan()
      panjang_vektor()
      pemecahan_panjang_vektor()
      sum_panjang_vektor()
      pemecahan_pembobotan()
      wd()
      pemecahan_wd()
      sum_wd()
      cosine_similarity()
      result()
    end

  end
  
  def text_preprocessing(text)
    #delete punctuation
    delete_punctuation = text.downcase.gsub(/[^a-z0-9\s]/i, '')
    #stopword removal
    stop_word_remover_factory = Sastrawi::StopWordRemover::StopWordRemoverFactory.new
    stopword                  = stop_word_remover_factory.create_stop_word_remover
    stopword_removal          = stopword.remove(delete_punctuation)
    #steaming
    stemmer_factory = Sastrawi::Stemmer::StemmerFactory.new
    stemmer         = stemmer_factory.create_stemmer
    result          = stemmer.stem(stopword_removal)
  end

  def document(input)
    @dokumen = []
    @dokumen.push(input.split)
    @book.each do |doc|
      @dokumen.push(text_preprocessing(doc.synopsis).split)
    end
  end

  def get_term(input)
    @kata = []
    @book.each do |word|
      @kata.push(text_preprocessing(word.synopsis))
    end
    kumpulan_kata = input + " " + @kata.join(" ")
    pemecahan_kata = kumpulan_kata.split
    @data_term = []
    pemecahan_kata.each do |term|
      @data_term.push(term)
    end
    @term = @data_term.uniq!
  end
  

  def idf()
    # @doc   = document()
    @n     = @dokumen.length
    @idf   = []
    @tf    = []
    @term.each do |word|
      @find_tf   = 0
      @dokumen.each do |document|
        counter = document.count(word)
        # puts "#{document} => #{word} : #{counter}"
        if counter >= 1
          @find_tf = @find_tf + 1
        end
        @tf.push(counter)
      end
      to_log = @n/@find_tf.to_f
      hitung = Math.log(to_log, 10)
      @idf.push(hitung)    
    end
  end

  def table_tf()
    @n     = @dokumen.length
    @data_tf = []
    @term.each do |t|
      flag = @tf.shift(@n)
      @data_tf.push(flag)
    end
    # puts @data_tf
  end

  def pembobotan()
    @data_perkata = []
    @idf.each do |n|
      perkata = @data_tf.shift
      perkata.each do |w|
        wdt = w * n
        @data_perkata.push(wdt)
      end
    end
  end

  def pemecahan_pembobotan()
    @data_pembobobotan = []
    @term.each do |t|
      flag = @data_perkata.shift(@n)
      @data_pembobobotan.push(flag)
    end
  end

  def wd()
    @data_wd = []
    # puts @data_pembobobotan
    @data_pembobobotan.each do |dp|
      # puts "dp f = #{dp}"
      flag = dp.shift(1)
      q = flag.shift
      # puts "dp l = #{dp} dan q = #{q}"
      dp.each do |f|
        hasil = q * f
        # puts "hasil = #{hasil}"
        @data_wd.push(hasil)
      end
    end
    # puts @data_wd
  end

  def pemecahan_wd()
    @n_book = @book.length
    @data_pecahan_wd = []
    @term.each do |t|
      flag = @data_wd.shift(@n_book)
      @data_pecahan_wd.push(flag)
    end
  end

  def sum_wd()
    @total_wd = @data_pecahan_wd.transpose.map {|x| x.reduce(:+)}
  end
  
  def panjang_vektor()
    @panjang_vektor = @data_perkata.map { |x| x * x}
  end

  def pemecahan_panjang_vektor()
    @data_panjang_vektor = []
    @term.each do |t|
      flag = @panjang_vektor.shift(@n)
      @data_panjang_vektor.push(flag)
    end
  end

  def sum_panjang_vektor()
    @sum_vektor = @data_panjang_vektor.transpose.map {|x| x.reduce(:+)}
    @sqrt_sum_vektor = @sum_vektor.map { |x| Math.sqrt(x)}
  end
  
  def cosine_similarity()
    @q_x_dokumen = []
    x = @sqrt_sum_vektor.shift
    @sqrt_sum_vektor.each do |akar_d|
      hasil = akar_d * x
      @q_x_dokumen.push(hasil)
    end
    @cos_sim = @total_wd.zip(@q_x_dokumen).map{|x, y| (x / y) }
  end
  
  def result()
    @result = Hash.new
    @book.each do |book|
      x = @cos_sim.shift
      if x > 0
        # @result[book.id] = x
        @result[x] = book
      end
      @ikihasile = @result.sort_by { |_key , value| -_key}.to_h
      
    end
    puts @result
  end
  
  
  

end