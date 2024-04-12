with Ada.Text_IO, GNAT.Semaphores; use Ada.Text_IO, GNAT.Semaphores;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Containers.Indefinite_Doubly_Linked_Lists; use Ada.Containers;

procedure Main is
   package Integer_Lists is new Indefinite_Doubly_Linked_Lists (Integer);
   use Integer_Lists;

   procedure Storage (Capacity: in Integer) is
   Items_Storage: List;
   Space_Available: Counting_Semaphore (Capacity, Default_Ceiling);
   Items_Avalable: Counting_Semaphore (0, Default_Ceiling);

    task type Producer is
          entry Start(Items_To_Produce : in Integer);
    end Producer;

      task type Consumer is
          entry Start(Items_To_Consume : in Integer);
      end Consumer;

   task body Producer is
       Items_To_Produce : Integer;
   begin
        accept Start (Items_To_Produce : in Integer) do
                Producer.Items_To_Produce := Items_To_Produce;
        end Start;
      for I in 0 .. Items_To_Produce loop
         Space_Available.Seize;
         Items_Storage.Append(I);
         Put_Line("Producer added item:" & I'Img);
         Items_Avalable.Release;

         --delay 2.5;
      end loop;
   end Producer;

   task body Consumer is
       Items_To_Consume : Integer;
   begin
       accept Start (Items_To_Consume : in Integer) do
                Consumer.Items_To_Consume := Items_To_Consume;
        end Start;
      for I in 0 .. Items_To_Consume loop
         Items_Avalable.Seize;

         declare
            Item: Integer := First_Element (Items_Storage);
         begin
            Put_Line("Consumer deleted item:" & Item'Img);
         end;

         Items_Storage.Delete_First;

         Space_Available.Release;
         --delay 1.5;
      end loop;
   end Consumer;
   
   type Producers_Array_Type is array (Integer range <>) of Producer;
    type Consumers_Array_Type is array (Integer range <>) of Consumer;
    Producers : Producers_Array_Type (1 .. 5);
    Consumers : Consumers_Array_Type (1 .. 3);

begin
  for I in Producers'Range loop
        Producers(I).Start(10);
    end loop;
    
    for J in Consumers'Range loop
            Consumers(J).Start(10);
    end loop;
end Storage;



begin
   Storage(10);
end Main;
