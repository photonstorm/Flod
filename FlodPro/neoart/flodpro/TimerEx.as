/* FlodPro Custom Controls
   2009/08/15
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flodpro {
  import flash.utils.*;

  public class TimerEx extends Timer {
    public var before:int;
    public var beforeRow:int;
    public var beforeColumn:int;
    public var tick:Number = 0.0;
    public var interval:Number = 0.0;
    public var intervalRow:Number = 0.0;
    public var intervalColumn:Number = 0.0;

    public function TimerEx(delay:Number, repeatCount:int = 0) {
      super(delay, repeatCount);
    }

    public function initialize():void {
      before = getTimer();
      beforeRow = before;
      beforeColumn = before;
      interval = tick;
      intervalRow = tick;
      intervalColumn = 0.0;
      delay = interval;
    }

    public function set():void {
      var now:int = getTimer();
      interval = tick - ((now - before) - tick);
      if (interval < 2) interval = 2;
      intervalRow += tick;
      before = now;
      delay = interval;
    }

    public function setRow():void {
      interval = tick - ((getTimer() - beforeRow) - intervalRow);
      if (interval < 2) interval = 2;
      before = beforeRow + int(intervalRow);
      beforeRow = before;
      intervalColumn += intervalRow;
      intervalRow = tick;
      delay = interval;
    }

    public function setColumn():void {
      intervalColumn += intervalRow;
      interval = tick - ((getTimer() - beforeColumn) - intervalColumn);
      if (interval < 2) interval = 2;
      before = beforeColumn + int(intervalColumn);
      beforeRow = before;
      beforeColumn = before;
      intervalColumn = 0;
      intervalRow = tick;
      delay = interval;
    }
  }
}