
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import javax.microedition.lcdui.Command;
import javax.microedition.lcdui.CommandListener;
import javax.microedition.lcdui.Display;
import javax.microedition.lcdui.Displayable;
import javax.microedition.lcdui.Form;
import javax.microedition.lcdui.Item;
import javax.microedition.lcdui.ItemCommandListener;
import javax.microedition.lcdui.StringItem;
import javax.microedition.midlet.MIDletStateChangeException;

public class Midlet extends javax.microedition.midlet.MIDlet
        implements CommandListener {

    final String data[][] = {
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Home\", \"id\": 1}", "home"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Up\", \"id\": 1}", "/\\"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Back\", \"id\": 1}", "<="},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Left\", \"id\": 1}", "<"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Select\", \"id\": 1}", "*"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Right\", \"id\": 1}", ">"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Info\", \"id\": 1}", "!"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.Down\", \"id\": 1}", "\\/"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Input.ContextMenu\", \"id\": 1}", "menu"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.PlayPause\", \"params\": { \"playerid\": 0 }, \"id\": 1}", "||>>"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.GoTo\", \"params\": { \"to\": \"previous\", \"playerid\": 0 }, \"id\": 1}", "<<|"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.GoTo\", \"params\": { \"to\": \"next\", \"playerid\": 0 }, \"id\": 1}", "|>>"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.Stop\", \"params\": { \"playerid\": 0 }, \"id\": 1}", "stop"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.SetSpeed\", \"params\": { \"playerid\": 0, \"speed\": \"decrement\" }, \"id\": 1}", "<<"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Player.SetSpeed\", \"params\": { \"playerid\": 0, \"speed\": \"increment\" }, \"id\": 1}", ">>"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Application.SetMute\", \"params\": { \"mute\": \"toggle\" }, \"id\": 1}", ")))x"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Application.SetVolume\", \"params\": { \"volume\": \"decrement\" }, \"id\": 1}", ")))---"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Application.SetVolume\", \"params\": { \"volume\": \"increment\" }, \"id\": 1}", ")))+++"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"System.Shutdown\", \"id\": 1}", "shutdown"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"System.Reboot\", \"id\": 1}", "reboot"},
        {"{\"jsonrpc\": \"2.0\", \"method\": \"Application.Quit\", \"id\": 1}", "quit"}
    };
    String url1 = "http://192.168.1.";
    int urlIndex = 2;
    String url3 = "/jsonrpc";
    String url;
    MyForm form;
    /*button1.addActionListener(new ActionListener() {
     public void actionPerformed(ActionEvent evt) {
     button1.setText("New Text");
     }
     });*/

    public void startApp() {
        url = url1 + urlIndex + url3;
        form = new MyForm("XBMC Controler");
        //form.addCommand(new Command("hi", Command.OK,1));
        Button b;
        for (int i = 0; i < data.length; i++) {
            b = new Button(form, data[i][1], data[i][0]);
            b.setLayout(Button.LAYOUT_NEWLINE_BEFORE | Button.LAYOUT_EXPAND);
            form.append(b);
        }
        Display.getDisplay(this).setCurrent(form);
    }

    public void pauseApp() {
    }

    protected void destroyApp(boolean unconditional) throws MIDletStateChangeException {
        throw new MIDletStateChangeException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    public void commandAction(Command c, Displayable d) {
        form.commandAction(c, null); //To change body of generated methods, choose Tools | Templates.
    }

    public class post extends Thread {

        String text;
        static public final String charset = "UTF-8";

        private post(String longLabel) {
            text = longLabel;
        }

        public void run() {
            try {
                HttpConnection c = null;
                InputStream is = null;
                OutputStream os = null;
                int rc;

                try {
                    c = (HttpConnection) Connector.open(url);
                    c.setRequestMethod("POST");

                    // Set the request method and headers
                    c.setRequestMethod(HttpConnection.POST);
                    c.setRequestProperty("If-Modified-Since",
                            "29 Oct 1999 19:43:31 GMT");
                    c.setRequestProperty("User-Agent",
                            "Profile/MIDP-2.0 Configuration/CLDC-1.0");
                    c.setRequestProperty("Content-Language", "en-US");
                    c.setRequestProperty("Accept-Charset", charset);
                    c.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                    c.setRequestProperty("Content-Length", "" + Integer.toString(text.getBytes().length));
                    /*
            
            
                     XHR.open('POST', '/jsonrpc');
                     XHR.setRequestHeader('Content-Type','application/json; charset=UTF-8');
                     XHR.setRequestHeader('Content-Length', data.length);

                     */
                    // Getting the output stream may flush the headers
                    os = c.openOutputStream();
                    os.write((text).getBytes());
                    os.flush();           // Optional, getResponseCode will flush

                    // Getting the response code will open the connection,
                    // send the request, and read the HTTP response headers.
                    // The headers are stored until requested.
                    rc = c.getResponseCode();
                    System.out.println("\nSending 'POST' request to URL : " + url);
                    System.out.println("Post parameters : " + text);
                    System.out.println("Response Code : " + rc);

                    if (rc != HttpConnection.HTTP_OK) {
                        throw new IOException("HTTP response code: " + rc);
                    }
                    /*
                    is = c.openInputStream();

                    // Get the length and process the data
                    int len = (int) c.getLength();
                    if (len > 0) {
                        int actual = 0;
                        int bytesread = 0;
                        byte[] data = new byte[len];
                        while ((bytesread != len) && (actual != -1)) {
                            actual = is.read(data, bytesread, len - bytesread);
                            bytesread += actual;
                        }
                        System.out.print(data);
                    }
                            */
                } catch (ClassCastException e) {
                    throw new IllegalArgumentException("Not an HTTP URL");
                } finally {
                    if (is != null) {
                        is.close();
                    }
                    if (os != null) {
                        os.close();
                    }
                    if (c != null) {
                        c.close();
                    }
                }

            } catch (IOException ex) {
                ex.printStackTrace();
                if(urlIndex < 10){
                    url = url1 + ++urlIndex + url3;
                    (new post(text)).start();
                }
            }
        }
    }


    public class MyForm extends Form implements ItemCommandListener {

        public MyForm(String str) {
            super(str);
        }

        public void commandAction(Command cmd, Item item) {
            (new post(cmd.getLongLabel()+"\n")).start();
        }
    }

    class Button extends StringItem {

        public Button(MyForm form, String text, String data) {
            super(null, text);
            super.setDefaultCommand(new Command(text, data, Command.OK, 1));
            super.setItemCommandListener(form);
        }
    }
}

