using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using Windows.Graphics.Imaging;
using Windows.Media.Ocr;
using Windows.Storage.Streams;
using Windows.Globalization;

class ScreenshotOCR
{
    [DllImport("ole32.dll")]
    static extern int CoInitializeEx(IntPtr pvReserved, uint dwCoInit);
    const uint COINIT_APARTMENTTHREADED = 0x2;

    static int Main(string[] args)
    {
        if (args.Length < 1)
        {
            Console.Error.WriteLine("Usage: ScreenshotOCR <image_path>");
            return 1;
        }

        string imagePath = args[0];
        if (!File.Exists(imagePath))
        {
            Console.Error.WriteLine("File not found: " + imagePath);
            return 1;
        }

        CoInitializeEx(IntPtr.Zero, COINIT_APARTMENTTHREADED);

        try
        {
            var task = Task.Run(async () => await OcrImageAsync(imagePath));
            task.Wait(30000);
            string result = task.Result;
            if (!string.IsNullOrEmpty(result))
                Console.WriteLine(result);
            else
                Console.WriteLine("(no text detected)");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("OCR Error: " + ex.Message);
            if (ex.InnerException != null)
                Console.Error.WriteLine("Inner: " + ex.InnerException.Message);
            return 1;
        }
    }

    static async Task<string> OcrImageAsync(string imagePath)
    {
        using (var bitmap = new Bitmap(imagePath))
        using (var ms = new MemoryStream())
        {
            bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
            ms.Seek(0, SeekOrigin.Begin);

            var stream = new InMemoryRandomAccessStream();
            var writer = new DataWriter(stream.GetOutputStreamAt(0));
            writer.WriteBytes(ms.ToArray());
            await writer.StoreAsync();

            var decoder = await BitmapDecoder.CreateAsync(stream);
            var softwareBitmap = await decoder.GetSoftwareBitmapAsync();

            // Try to find a Chinese OCR engine
            OcrEngine engine = null;
            foreach (var lang in OcrEngine.AvailableRecognizerLanguages)
            {
                if (lang.LanguageTag.StartsWith("zh"))
                {
                    engine = OcrEngine.TryCreateFromLanguage(lang);
                    break;
                }
            }
            if (engine == null)
                engine = OcrEngine.TryCreateFromUserProfileLanguages();

            if (engine == null)
                return "(no OCR engine)";

            var result = await engine.RecognizeAsync(softwareBitmap);
            var lines = new System.Text.StringBuilder();
            foreach (var line in result.Lines)
            {
                if (lines.Length > 0) lines.AppendLine();
                lines.Append(line.Text);
            }
            return lines.ToString();
        }
    }
}

// Helper: In-memory IRandomAccessStream
public class InMemoryRandomAccessStream : IRandomAccessStream
{
    private Stream _stream;
    private ulong _size;

    public InMemoryRandomAccessStream()
    {
        _stream = new MemoryStream();
    }

    public bool CanRead => true;
    public bool CanWrite => true;
    public ulong Position => (ulong)_stream.Position;
    public ulong Size { get => _size; set => _size = value; }

    public IInputStream GetInputStreamAt(ulong position)
    {
        _stream.Seek((long)position, SeekOrigin.Begin);
        return new InputStreamWrapper(_stream);
    }

    public IOutputStream GetOutputStreamAt(ulong position)
    {
        _stream.Seek((long)position, SeekOrigin.Begin);
        return new OutputStreamWrapper(_stream);
    }

    public IRandomAccessStream CloneStream() => new InMemoryRandomAccessStream();
    public void Seek(ulong position) { _stream.Seek((long)position, SeekOrigin.Begin); }
    public void Dispose() { _stream.Dispose(); }

    public Windows.Foundation.IAsyncOperationWithProgress<IBuffer, uint> ReadAsync(IBuffer buffer, uint count, InputStreamOptions options)
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<IBuffer, uint>((token, progress) =>
        {
            return Task.Run(() =>
            {
                byte[] data = new byte[count];
                int read = _stream.Read(data, 0, (int)count);
                if (buffer != null) data.CopyTo(0, buffer, 0, read);
                buffer.Length = (uint)read;
                progress.Report((uint)read);
                return buffer;
            });
        });
    }

    public Windows.Foundation.IAsyncOperation<bool> FlushAsync()
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<bool>((token) =>
        {
            return Task.Run(() =>
            {
                _stream.Flush();
                return true;
            });
        });
    }

    public Windows.Foundation.IAsyncOperationWithProgress<uint, uint> WriteAsync(IBuffer buffer)
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<uint, uint>((token, progress) =>
        {
            return Task.Run(() =>
            {
                byte[] data = new byte[buffer.Length];
                buffer.CopyTo(0, data, 0, (int)buffer.Length);
                _stream.Write(data, 0, (int)buffer.Length);
                _size = (ulong)_stream.Length;
                progress.Report(buffer.Length);
                return buffer.Length;
            });
        });
    }
}

public class InputStreamWrapper : IInputStream
{
    private Stream _stream;
    public InputStreamWrapper(Stream stream) { _stream = stream; }

    public Windows.Foundation.IAsyncOperationWithProgress<IBuffer, uint> ReadAsync(IBuffer buffer, uint count, InputStreamOptions options)
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<IBuffer, uint>((token, progress) =>
        {
            return Task.Run(() =>
            {
                byte[] data = new byte[count];
                int read = _stream.Read(data, 0, (int)count);
                if (buffer != null) data.CopyTo(0, buffer, 0, read);
                buffer.Length = (uint)read;
                progress.Report((uint)read);
                return buffer;
            });
        });
    }

    public void Dispose() { }
}

public class OutputStreamWrapper : IOutputStream
{
    private Stream _stream;
    public OutputStreamWrapper(Stream stream) { _stream = stream; }

    public Windows.Foundation.IAsyncOperationWithProgress<uint, uint> WriteAsync(IBuffer buffer)
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<uint, uint>((token, progress) =>
        {
            return Task.Run(() =>
            {
                byte[] data = new byte[buffer.Length];
                buffer.CopyTo(0, data, 0, (int)buffer.Length);
                _stream.Write(data, 0, (int)buffer.Length);
                progress.Report(buffer.Length);
                return buffer.Length;
            });
        });
    }

    public Windows.Foundation.IAsyncOperation<bool> FlushAsync()
    {
        return System.Runtime.InteropServices.WindowsRuntime.AsyncInfo.Run<bool>((token) =>
        {
            return Task.Run(() =>
            {
                _stream.Flush();
                return true;
            });
        });
    }

    public void Dispose() { }
}
