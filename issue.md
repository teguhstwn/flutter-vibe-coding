# Issue: Peningkatan Fitur Halaman Product (Search, Edit, Delete)

## Deskripsi Tugas
Tugas ini fokus pada penyempurnaan fitur pengelolaan produk (CRUD lanjutan) pada aplikasi Flutter yang mengimplementasikan **Clean Architecture**, **BLoC (State Management)**, **Hive (Local Database)**, **GetIt (Dependency Injection)**, dan **GoRouter (Navigasi)**.

## Target Implementasi
1. Pada menu Product (`product_page.dart`), tambahkan sebuah **Search Bar** (kolom pencarian) tepat di bawah AppBar / batas atas halaman. Search bar ini berfungsi memfilter daftar produk berdasarkan nama produk secara *real-time*.
2. Pada *card* daftar produk (item product), tambahkan icon **Edit** dan **Delete**.
   - Jika icon **Delete** diklik, tampilkan dialog konfirmasi. Jika "Ya", hapus data menggunakan metode **Soft Delete** (menandai data sebagai dihapus dengan flag, tanpa benar-benar membuangnya dari database Hive) lalu perbarui tampilan daftar produk.
   - Jika icon **Edit** diklik, navigasikan user ke halaman form (dapat menggunakan ulang halaman tambah produk atau halaman baru) yang kolomnya sudah terisi dengan data produk tersebut. Setelah disimpan, data di database akan di-*update* dan list produk diperbarui otomatis.

---

## Tahapan Implementasi (Step-by-Step)
Silakan ikuti instruksi berikut secara berurutan agar sesuai dengan standar arsitektur proyek (*Clean Architecture*).

### Tahap 1: Domain Layer (Aturan Bisnis)
Fokus pada *interface*, *Entity*, dan *Use Case*.

1. **Update Entity (Soft Delete Support):**
   - Buka `lib/domain/entities/product.dart`.
   - Tambahkan properti `bool isDeleted` (dengan nilai bawaan / *default* `false`).
   - **Penting:** Pastikan untuk mengupdate juga `ProductModel` (`lib/data/models/product_model.dart`) dengan anotasi HiveField baru, lalu jalankan `dart run build_runner build -d` agar generated file `.g.dart` diperbarui.
2. **Update Repository Interface:**
   - Buka `lib/domain/repositories/product_repository.dart`.
   - Tambahkan dua metode abstrak:
     ```dart
     Future<void> updateProduct(Product product);
     Future<void> deleteProduct(String id);
     ```
2. **Buat Use Cases Baru:**
   - Buat file `lib/domain/usecases/update_product.dart`. Implementasikan *call* ke `repository.updateProduct(product)`.
   - Buat file `lib/domain/usecases/delete_product.dart`. Implementasikan *call* ke `repository.deleteProduct(id)`.

### Tahap 2: Data Layer (Implementasi Database Lokal)
Fokus pada interaksi dengan Hive.

1. **Update Local Data Source:**
   - Buka `lib/data/datasources/product_local_data_source.dart`.
   - Tambahkan fungsi pada *interface* dan implementasinya:
     - `updateProduct`: gunakan `productBox.put(product.id, product)` untuk menimpa data berdasar ID.
     - `deleteProduct` (**Soft Delete**): Ambil data `ProductModel` berdasarkan ID, ubah field `isDeleted` menjadi `true`, lalu simpan kembali atau timpa data lamanya menggunakan `productBox.put(id, updatedProduct)`.
     - `getProducts`: Update metode *fetch* agar menyaring (filter) data yang `isDeleted == false` agar produk yang sudah dihapus tidak ikut tampil di UI.
2. **Update Repository Implementation:**
   - Buka `lib/data/repositories/product_repository_impl.dart`.
   - Implementasikan fungsi `updateProduct` dan `deleteProduct` dengan memanggil metode dari `localDataSource` yang telah dibuat.

### Tahap 3: Dependency Injection
Mendaftarkan komponen baru ke sistem DI.

1. **Update Injection:**
   - Buka `lib/injection.dart`.
   - Daftarkan kedua Use Case baru tadi menggunakan `sl.registerLazySingleton`.
   - Pastikan constructor `ProductBloc` nanti menerima tambahan dependensi Use Case tersebut.

### Tahap 4: Presentation Layer - BLoC (State Management)
Mengatur arus data dan event untuk UI.

1. **Update Events:**
   - Buka `lib/presentation/bloc/product/product_bloc.dart`.
   - Tambahkan event baru:
     - `UpdateProductEvent(Product product)`
     - `DeleteProductEvent(String id)`
     - `SearchProductEvent(String query)`
2. **Implementasi Logic BLoC:**
   - Tambahkan parameter `UpdateProduct` dan `DeleteProduct` di constructor `ProductBloc`.
   - Buat handler untuk `UpdateProductEvent`: panggil use case update, sukses -> set state success, trigger event load ulang.
   - Buat handler untuk `DeleteProductEvent`: panggil use case delete, sukses -> trigger event load ulang.
   - Buat handler untuk pencarian (`SearchProductEvent`):
     - Anda dapat menangani *search* dengan membuat state lokal berisi seluruh data (menghindari fetch database berulang) lalu memfilternya, ATAU memfilter data secara reaktif setiap kali event dipanggil. 
     - Petunjuk: Untuk pemula, memegang *all products* saat `LoadProductsEvent` lalu meng-emit `ProductLoaded` hasil filter dari `where((p) => p.name.toLowerCase().contains(query))` adalah cara paling simpel.

### Tahap 5: Presentation Layer - UI (Tampilan)
1. **Search Bar:**
   - Di `product_page.dart`, ubah bagian `body` agar mencakup `Column`.
   - Tambahkan `TextField` berdesain menarik (gunakan icon *search*, *outline border*) di posisi atas kolom.
   - Gunakan properti `onChanged` pada `TextField` untuk memanggil `context.read<ProductBloc>().add(SearchProductEvent(value))`.
2. **Icon Edit & Delete:**
   - Pada `ListTile` item produk, ubah bagian `trailing` untuk menampung `Row` berisi dua `IconButton` (Edit & Delete).
   - Pastikan warna menyesuaikan (*merah* untuk hapus, *biru/abu* untuk edit) dan tambahkan batas `mainAxisSize: MainAxisSize.min` pada `Row` agar tidak rusak layoutnya.
3. **Konfirmasi Delete:**
   - Saat tombol delete di-klik, panggil `showDialog` yang menampilkan `AlertDialog` konfirmasi. Jika user memilih 'Ya', jalankan event `DeleteProductEvent`.
4. **Halaman Edit Produk:**
   - Anda perlu melakukan sedikit refactoring. Halaman `add_product_page.dart` dapat direkayasa agar menerima parameter `Product? product`. Jika `product != null`, ubah judul halaman menjadi "Edit Produk" dan isi `TextEditingController` dengan data produk lama.
   - Pada `app_router.dart`, daftarkan rute baru (misal `/edit-product`) yang menyertakan data (menggunakan properti *extra* di GoRouter).
   - Saat tombol simpan pada halaman "Edit Produk" ditekan, *trigger* `UpdateProductEvent` dan bukan `AddProductEvent`.

Selamat mengerjakan! Pastikan kode bersih, ikuti standar aturan linting, dan biasakan cek ulang hasil *mapping* data sebelum tes dijalankan.
