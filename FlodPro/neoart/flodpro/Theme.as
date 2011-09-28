/* FlodPro Colors
   2009/08/15
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flodpro {

  public class Theme {
    public static const PANEL_BACKGROUND:int = 0x0a0c0e;

    public static const LABEL_BUTTON:  int = 0x000000;
    public static const LABEL_COLOR:   int = 0xdee0e2;
    public static const LABEL_DISABLED:int = 0xacaeb0;
    public static const LABEL_PATTERN: int = 0x5566ff;
    public static const LABEL_VERSION: int = 0xc4c6c8;

    public static const BUTTON:Array = [
      [0xbec0c2, 0x46484a, 0x8c8e90],     //normal
      [0xbecae0, 0x465268, 0x8c98ae],     //hover
      [0x7a7c7e, 0x46484a, 0x8c8e90],     //hover pressed
      [0x7a7c7e, 0x7a7c7e, 0xa0a2a4],     //pressed
      [0xb6b8ba, 0x646668, 0x8c8e90]];    //disabled

    public static const BUTTON_STATE_ON: int = 0x82b482;
    public static const BUTTON_STATE_OFF:int = 0x646668;

    public static const SLIDER_TRACK_DEFAULT: int = 0x6e7072;
    public static const SLIDER_TRACK_SELECTED:int = 0xacaeb0;
    public static const SLIDER_CURSOR_BORDER: int = 0x46484a;
    public static const SLIDER_CURSOR_FACE:   int = 0x6e7072;

    public static const FONT_DEFAULT:String = "FlodPro";
    public static const FONT_BOLD:   String = "FlodProBold";
  }
}