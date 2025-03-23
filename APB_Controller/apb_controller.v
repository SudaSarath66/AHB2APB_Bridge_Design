// AHB to APG Bridge | Maven Silicon
//
//
// APB FSM Controller
// Date:08-06-2022
// By-Prajwal Kumar Sahu

module apb_controller( Hclk,Hresetn,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwritereg,tempselx, 
                           Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

input Hclk,Hresetn,valid,Hwrite,Hwritereg;
input [31:0] Hwdata,Haddr,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata;
input [2:0] tempselx;
output reg Pwrite,Penable;
output reg Hreadyout;  
output reg [2:0] Pselx;
output reg [31:0] Paddr,Pwdata;

//////////////////////////////////////////////////////PARAMETERS

parameter ST_IDLE=3'b000;
parameter ST_WWAIT=3'b001;
parameter ST_READ= 3'b010;
parameter ST_WRITE=3'b011;
parameter ST_WRITEP=3'b100;
parameter ST_RENABLE=3'b101;
parameter ST_WENABLE=3'b110;
parameter ST_WENABLEP=3'b111;


//////////////////////////////////////////////////// PRESENT STATE LOGIC

reg [2:0] PRESENT_STATE,NEXT_STATE;

always @(posedge Hclk)
 begin:PRESENT_STATE_LOGIC
  if (~Hresetn)
    PRESENT_STATE<=ST_IDLE;
  else
    PRESENT_STATE<=NEXT_STATE;
 end


/////////////////////////////////////////////////////// NEXT STATE LOGIC

always @(PRESENT_STATE,valid,Hwrite,Hwritereg)
 begin:NEXT_STATE_LOGIC
  case (PRESENT_STATE)
    
    ST_IDLE:begin
         if (~valid)
          NEXT_STATE=ST_IDLE;
         else if (valid && Hwrite)
          NEXT_STATE=ST_WWAIT;
         else 
          NEXT_STATE=ST_READ;
        end    

    ST_WWAIT:begin
         if (~valid)
          NEXT_STATE=ST_WRITE;
         else
          NEXT_STATE=ST_WRITEP;
        end

    ST_READ: begin
           NEXT_STATE=ST_RENABLE;
         end

    ST_WRITE:begin
          if (~valid)
           NEXT_STATE=ST_WENABLE;
          else
           NEXT_STATE=ST_WENABLEP;
         end

    ST_WRITEP:begin
           NEXT_STATE=ST_WENABLEP;
          end

    ST_RENABLE:begin
             if (~valid)
              NEXT_STATE=ST_IDLE;
             else if (valid && Hwrite)
              NEXT_STATE=ST_WWAIT;
             else
              NEXT_STATE=ST_READ;
           end

    ST_WENABLE:begin
             if (~valid && Hwritereg) 
              NEXT_STATE=ST_IDLE;
             else if (valid && Hwritereg)
              NEXT_STATE=ST_WWAIT;
             else if (valid && ~Hwritereg)
              NEXT_STATE=ST_READ;
            end

    ST_WENABLEP:begin
                 if (~valid && Hwritereg) 
                  NEXT_STATE=ST_IDLE;
                 else if (valid && Hwritereg)
                  NEXT_STATE=ST_WWAIT;
                 else if (valid && ~Hwritereg)
                  NEXT_STATE=ST_READ;
                end
    
    default: NEXT_STATE=ST_IDLE;

 endcase
end

////////////////////////////////////////////////////////OUTPUT LOGIC:COMBINATIONAL

reg [31:0] Paddr_temp,Pwdata_temp;
reg Pwrite_temp,Penable_temp,Hreadyout_temp;
reg [2:0] Pselx_temp;

always @(PRESENT_STATE,valid,Haddr,Haddr1,Haddr2,Hwrite,Hwdata,Hwdata1,Hwdata2,Prdata,tempselx)
 begin
    Paddr_temp=Paddr;
    Pwrite_temp=Pwrite;
    Pselx_temp=Pselx;
    Pwdata_temp=Pwdata;
    Penable_temp=Penable;
    Hreadyout_temp=Hreadyout;
    
    case(PRESENT_STATE)

      ST_IDLE:begin
                Paddr_temp=0;
                Pwrite_temp=0;
                Pselx_temp=0;
                Pwdata_temp=0;
                Penable_temp=0;
                Hreadyout_temp=1;
              end

      ST_WWAIT:begin
                Paddr_temp=Haddr;
                Pwrite_temp=Hwrite;
                Pselx_temp=tempselx;
                Pwdata_temp=Hwdata;
                Penable_temp=0;
                Hreadyout_temp=0;
               end

      ST_READ:begin
                Paddr_temp=Haddr;
                Pwrite_temp=0;
                Pselx_temp=tempselx;
                Pwdata_temp=0;
                Penable_temp=1;
                Hreadyout_temp=0;
              end
      
      ST_WRITE:begin
                Paddr_temp=Haddr;
                Pwrite_temp=Hwrite;
                Pselx_temp=tempselx;
                Pwdata_temp=Hwdata;
                Penable_temp=1;
                Hreadyout_temp=0;
               end

      ST_WRITEP:begin
                 Paddr_temp=Haddr1;
                 Pwrite_temp=Hwrite;
                 Pselx_temp=tempselx;
                 Pwdata_temp=Hwdata1;
                 Penable_temp=1;
                 Hreadyout_temp=0;
                end

      ST_RENABLE:begin
                  if (valid && ~Hwrite)
                    begin:RENABLE_TO_READ
                        Paddr_temp=Haddr;
                        Pwrite_temp=Hwrite;
                        Pselx_temp=tempselx;
                        Penable_temp=0;
                        Hreadyout_temp=0;
                    end
                  else if (valid && Hwrite)
                    begin:RENABLE_TO_WWAIT
                        Pselx_temp=0;
                        Penable_temp=0;
                        Hreadyout_temp=1;
                    end
                  else
                    begin:RENABLE_TO_IDLE
                        Pselx_temp=0;
                        Penable_temp=0;
                        Hreadyout_temp=1;
                    end
                 end

      ST_WENABLEP:begin
                   if (~valid && Hwritereg) 
                    begin:WENABLEP_TO_WRITEP
                       Paddr_temp=Haddr2;
                       Pwrite_temp=Hwrite;
                       Pselx_temp=tempselx;
                       Penable_temp=0;
                       Pwdata_temp=Hwdata;
                       Hreadyout_temp=0;
                      end
                    else 
                     begin:WENABLEP_TO_WRITE_OR_READ
                      Paddr_temp=Haddr2;
                      Pwrite_temp=Hwrite;
                      Pselx_temp=tempselx;
                      Pwdata_temp=Hwdata;
                      Penable_temp=0;
                      Hreadyout_temp=0;
                     end
                   end

      ST_WENABLE:begin
                   if (~valid && Hwritereg) 
                    begin:WENABLE_TO_IDLE
                     Pselx_temp=0;
                     Penable_temp=0;
                     Hreadyout_temp=0;
                    end
                    else 
                     begin:WENABLE_TO_WAIT_OR_READ
                      Pselx_temp=0;
                      Penable_temp=0;
                      Hreadyout_temp=0;
                     end
                  end

    endcase
end

////////////////////////////////////////////////////////OUTPUT LOGIC:SEQUENTIAL

always @(posedge Hclk)
 begin
 
  if (~Hresetn)
   begin
    Paddr<=0;
    Pwrite<=0;
    Pselx<=0;
    Pwdata<=0;
    Penable<=0;
    Hreadyout<=0;
   end
 
  else
   begin
        Paddr<=Paddr_temp;
        Pwrite<=Pwrite_temp;
        Pselx<=Pselx_temp;
        Pwdata<=Pwdata_temp;
        Penable<=Penable_temp;
        Hreadyout<=Hreadyout_temp;
   end
 end

endmodule
