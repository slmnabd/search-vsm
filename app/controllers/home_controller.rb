require 'sastrawi'

class HomeController < ApplicationController
  helper_method :delete_punctuation, :steamming, :stopword_removal
  def index
    @book = Book.all
    @books = Book.all
    @hasil_search = params[:search]
    # delete_punctuation(@hasil_search)
    # steamming(@hasil_search)
    # stopword_removal(@hasil_search)
    if params[:search]
      @books = Book.where('title like ?', "%#{params[:search]}%")
      @books = Book.where('author like ?', "%#{params[:search]}%")
      @query_input = text_preprocessing(params[:search])
      document(@query_input)
      get_term(@query_input)
      idf()
      table_tf()
      pembobotan()
      panjang_vektor()
      pemecahan_pembobotan()
      pemecahan_panjang_vektor()
      sum_panjang_vektor()
      wd()
      pemecahan_wd()
      sum_wd()
      cosine_similarity()
      result()
    end

  end
  
  def text_preprocessing(text)
    #delete punctuation
    # @delete_punctuation = text.downcase.gsub(/[^a-z0-9\s]/i, '')
    @delete_punctuation = delete_punctuation(text)
    
    #steaming
    # stemmer_factory = Sastrawi::Stemmer::StemmerFactory.new
    # stemmer         = stemmer_factory.create_stemmer
    # @text_steamming = stemmer.stem(@delete_punctuation)
    @text_steamming = steamming(@delete_punctuation)
    #stopword removal
    # stop_word_remover_factory = Sastrawi::StopWordRemover::StopWordRemoverFactory.new
    # stopword                  = stop_word_remover_factory.create_stop_word_remover
    # @result_text              = stopword.remove(@text_steamming)
    @result_text              = stopword_removal(@text_steamming)
  end

  def delete_punctuation(text)
    result = text.downcase.gsub(/[^a-z0-9\s]/i, '')
  end

  def steamming(text)
    stemmer_factory = Sastrawi::Stemmer::StemmerFactory.new
    stemmer         = stemmer_factory.create_stemmer
    text_steamming  = stemmer.stem(text)
  end
  
  def stopword_removal(text)
    # stop_words_factory delete : satu
    stop_words_factory = %w[a ada adalah adanya adapun agak agaknya agar akan
          akankah akhir akhiri akhirnya aku akulah amat amatlah anda andalah
          antar antara antaranya apa apaan apabila apakah apalagi apatah arti
          artinya asal asalkan atas atau ataukah ataupun awal awalnya b bagai
          bagaikan bagaimana bagaimanakah bagaimanapun bagainamakah bagi bagian
          bahkan bahwa bahwasannya bahwasanya baik baiklah bakal bakalan balik
          banyak bapak baru bawah beberapa begini beginian beginikah beginilah
          begitu begitukah begitulah begitupun bekerja belakang belakangan
          belum belumlah benar benarkah benarlah berada berakhir berakhirlah
          berakhirnya berapa berapakah berapalah berapapun berarti berawal
          berbagai berdatangan beri berikan berikut berikutnya berjumlah
          berkali-kali berkata berkehendak berkeinginan berkenaan berlainan
          berlalu berlangsung berlebihan bermacam bermacam-macam bermaksud
          bermula bersama bersama-sama bersiap bersiap-siap bertanya
          bertanya-tanya berturut berturut-turut bertutur berujar berupa besar
          betul betulkah biasa biasanya bila bilakah bisa bisakah boleh bolehkah
          bolehlah buat bukan bukankah bukanlah bukannya bulan bung c cara
          caranya cukup cukupkah cukuplah cuma d dahulu dalam dan dapat dari
          daripada datang dekat demi demikian demikianlah dengan depan di dia
          diakhiri diakhirinya dialah diantara diantaranya diberi diberikan
          diberikannya dibuat dibuatnya didapat didatangkan digunakan
          diibaratkan diibaratkannya diingat diingatkan diinginkan dijawab
          dijelaskan dijelaskannya dikarenakan dikatakan dikatakannya dikerjakan
          diketahui diketahuinya dikira dilakukan dilalui dilihat dimaksud
          dimaksudkan dimaksudkannya dimaksudnya diminta dimintai dimisalkan
          dimulai dimulailah dimulainya dimungkinkan dini dipastikan diperbuat
          diperbuatnya dipergunakan diperkirakan diperlihatkan diperlukan
          diperlukannya dipersoalkan dipertanyakan dipunyai diri dirinya
          disampaikan disebut disebutkan disebutkannya disini disinilah
          ditambahkan ditandaskan ditanya ditanyai ditanyakan ditegaskan
          ditujukan ditunjuk ditunjuki ditunjukkan ditunjukkannya ditunjuknya
          dituturkan dituturkannya diucapkan diucapkannya diungkapkan dong dua
          dulu e empat enak enggak enggaknya entah entahlah f g guna gunakan h
          hadap hai hal halo hallo hampir hanya hanyalah hari harus haruslah
          harusnya helo hello hendak hendaklah hendaknya hingga i ia ialah
          ibarat ibaratkan ibaratnya ibu ikut ingat ingat-ingat ingin inginkah
          inginkan ini inikah inilah itu itukah itulah j jadi jadilah jadinya
          jangan jangankan janganlah jauh jawab jawaban jawabnya jelas jelaskan
          jelaslah jelasnya jika jikalau juga jumlah jumlahnya justru k kadar
          kala kalau kalaulah kalaupun kali kalian kami kamilah kamu kamulah kan
          kapan kapankah kapanpun karena karenanya kasus kata katakan katakanlah
          katanya ke keadaan kebetulan kecil kedua keduanya keinginan kelamaan
          kelihatan kelihatannya kelima keluar kembali kemudian kemungkinan
          kemungkinannya kena kenapa kepada kepadanya kerja kesampaian
          keseluruhan keseluruhannya keterlaluan ketika khusus khususnya kini
          kinilah kira kira-kira kiranya kita kitalah kok kurang l lagi lagian
          lah lain lainnya laku lalu lama lamanya langsung lanjut lanjutnya
          lebih lewat lihat lima luar m macam maka makanya makin maksud malah
          malahan mampu mampukah mana manakala manalagi masa masalah masalahnya
          masih masihkah masing masing-masing masuk mata mau maupun melainkan
          melakukan melalui melihat melihatnya memang memastikan memberi
          memberikan membuat memerlukan memihak meminta memintakan memisalkan
          memperbuat mempergunakan memperkirakan memperlihatkan mempersiapkan
          mempersoalkan mempertanyakan mempunyai memulai memungkinkan menaiki
          menambahkan menandaskan menanti menanti-nanti menantikan menanya
          menanyai menanyakan mendapat mendapatkan mendatang mendatangi
          mendatangkan menegaskan mengakhiri mengapa mengatakan mengatakannya
          mengenai mengerjakan mengetahui menggunakan menghendaki mengibaratkan
          mengibaratkannya mengingat mengingatkan menginginkan mengira
          mengucapkan mengucapkannya mengungkapkan menjadi menjawab menjelaskan
          menuju menunjuk menunjuki menunjukkan menunjuknya menurut menuturkan
          menyampaikan menyangkut menyatakan menyebutkan menyeluruh menyiapkan
          merasa mereka merekalah merupakan meski meskipun meyakini meyakinkan
          minta mirip misal misalkan misalnya mohon mula mulai mulailah mulanya
          mungkin mungkinkah n nah naik namun nanti nantinya nya nyaris nyata
          nyatanya o oleh olehnya orang p pada padahal padanya pak paling
          panjang pantas para pasti pastilah penting pentingnya per percuma
          perlu perlukah perlunya pernah persoalan pertama pertama-tama
          pertanyaan pertanyakan pihak pihaknya pukul pula pun punya q r rasa
          rasanya rupa rupanya s saat saatnya saja sajalah salam saling sama
          sama-sama sambil sampai sampai-sampai sampaikan sana sangat sangatlah
          sangkut saya sayalah se sebab sebabnya sebagai sebagaimana
          sebagainya sebagian sebaik sebaik-baiknya sebaiknya sebaliknya
          sebanyak sebegini sebegitu sebelum sebelumnya sebenarnya seberapa
          sebesar sebetulnya sebisanya sebuah sebut sebutlah sebutnya secara
          secukupnya sedang sedangkan sedemikian sedikit sedikitnya seenaknya
          segala segalanya segera seharusnya sehingga seingat sejak sejauh
          sejenak sejumlah sekadar sekadarnya sekali sekali-kali sekalian
          sekaligus sekalipun sekarang sekaranglah sekecil seketika sekiranya
          sekitar sekitarnya sekurang-kurangnya sekurangnya sela selain selaku
          selalu selama selama-lamanya selamanya selanjutnya seluruh seluruhnya
          semacam semakin semampu semampunya semasa semasih semata semata-mata
          semaunya sementara semisal semisalnya sempat semua semuanya semula
          sendiri sendirian sendirinya seolah seolah-olah seorang sepanjang
          sepantasnya sepantasnyalah seperlunya seperti sepertinya sepihak
          sering seringnya serta serupa sesaat sesama sesampai sesegera sesekali
          seseorang sesuatu sesuatunya sesudah sesudahnya setelah setempat
          setengah seterusnya setiap setiba setibanya setidak-tidaknya
          setidaknya setinggi seusai sewaktu siap siapa siapakah siapapun sini
          sinilah soal soalnya suatu sudah sudahkah sudahlah supaya t tadi
          tadinya tahu tak tambah tambahnya tampak tampaknya tandas tandasnya
          tanpa tanya tanyakan tanyanya tapi tegas tegasnya telah tempat tentang
          tentu tentulah tentunya tepat terakhir terasa terbanyak terdahulu
          terdapat terdiri terhadap terhadapnya teringat teringat-ingat terjadi
          terjadilah terjadinya terkira terlalu terlebih terlihat termasuk
          ternyata tersampaikan tersebut tersebutlah tertentu tertuju terus
          terutama tetap tetapi tiap tiba tiba-tiba tidak tidakkah tidaklah tiga
          toh tuju tunjuk turut tutur tuturnya u ucap ucapnya ujar ujarnya
          umumnya ungkap ungkapnya untuk usah usai v w waduh wah wahai waktunya
          walau walaupun wong x y ya yaitu yakin yakni yang z
        ]
    
    
    words = text.split(' ')
    stop_words = []
    
    words.each do |word|
      unless stop_words_factory.include?(word)
        stop_words.push(word)
      end
    end
    text_stopword = stop_words.join(' ')

    # stop_word_remover_factory = Sastrawi::StopWordRemover::StopWordRemoverFactory.new
    # stopword                  = stop_word_remover_factory.create_stop_word_remover
    # text_stopword             = stopword.remove(text)
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
    @tabel_data_tf = []
    @term.each do |t|
      flag = @tf.shift(@n)
      @data_tf.push(flag)
      @tabel_data_tf.push(flag)
    end
  end

  def pembobotan()
    @data_perkata = []
    @tabel_data_perkata = []
    @idf.each do |n|
      perkata = @data_tf.shift
      perkata.each do |w|
        wdt = w * n
        @data_perkata.push(wdt)
        @tabel_data_perkata.push(wdt)
      end
    end
    # puts @data_perkata
  end

  def pemecahan_pembobotan()
    @data_pembobobotan = []
    # @tabel_data_pembobobotan = []
    @term.each do |t|
      flag = @data_perkata.shift(@n)
      @data_pembobobotan.push(flag)
      # @tabel_data_pembobobotan.push(flag)
    end
    # puts @data_pembobobotan
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
    @tabel_sqrt_sum_vektor = @sum_vektor.map { |x| Math.sqrt(x)}
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
    # puts @result
  end
  
  
  

end